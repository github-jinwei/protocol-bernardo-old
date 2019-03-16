//
//  Device.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PhysicalDevice.hpp"
#include "PositionAcquisitionEngine.hpp"

// OpenCV Header
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

void PhysicalDevice::connect() {
    if(_state != DEVICE_IDLE) { return; }

    _state = DeviceState::DEVICE_CONNECTING;
    
    // Open the device
    if (_device.open(_uri.c_str()) != openni::STATUS_OK)
    {
        printf("Coudle not open the device:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    _device.setDepthColorSyncEnabled(true);
    
    // ////////////////////////
    // Create the color stream
    if(_colorStream.create(_device, openni::SENSOR_COLOR) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    // Set its properties
    openni::VideoMode colorVideoMode;
    colorVideoMode.setResolution(640, 480);
    colorVideoMode.setFps(30);
    colorVideoMode.setPixelFormat(openni::PIXEL_FORMAT_RGB888);
    _colorStream.setVideoMode(colorVideoMode);
    _colorStreamListener.device = this;
    _colorStream.addNewFrameListener(&_colorStreamListener);
    _colorStream.setMirroringEnabled(true);
    
    
    // ////////////////////////
    // Create the depth stream
    
    if(_depthStream.create(_device, openni::SENSOR_DEPTH) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    // Set its properties
    openni::VideoMode depthVideoMode;
    depthVideoMode.setResolution(640, 480);
    depthVideoMode.setFps(30);
    depthVideoMode.setPixelFormat(openni::PIXEL_FORMAT_DEPTH_1_MM);
    _depthStream.setVideoMode(depthVideoMode);
    _depthStreamListener.device = this;
    _depthStream.addNewFrameListener(&_depthStreamListener);
    
    
    // Set the registration mode
    _device.setImageRegistrationMode(openni::IMAGE_REGISTRATION_DEPTH_TO_COLOR);
    
    // Init the user tracker
    _rigTracker.create(&_device);
    _rigTracker.setSkeletonSmoothingFactor(.25f);
    _usersTracker._device = this;
    _rigTracker.addNewFrameListener(&_usersTracker);
    
    // Mark the device as ready
    _state = DeviceState::DEVICE_READY;

    if(_pae->isLiveViewEnabled()) {
        cv::namedWindow(_serial, cv::WINDOW_AUTOSIZE);
    }
}

void PhysicalDevice::setActive() {
    // Do nothing if the device is not ready to stream
    if(_state != DeviceState::DEVICE_READY)
        return;

    // Start the streams
    if(_colorStream.start() != openni::STATUS_OK) {
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    if(_depthStream.start() != openni::STATUS_OK) {
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    _state = DeviceState::DEVICE_ACTIVE;
}

void PhysicalDevice::setIdle() {
    if(_state == DeviceState::DEVICE_ACTIVE) {
        _colorStream.stop();
        _depthStream.stop();
        _state = DeviceState::DEVICE_READY;
    }
}

void PhysicalDevice::storeColorFrame(openni::VideoFrameRef *frame) {
    if(_colorFrame != nullptr)
        delete _colorFrame;
    
    _colorFrame = frame;
}

void PhysicalDevice::storeDepthFrame(openni::VideoFrameRef *frame) {
    if(_depthFrame != nullptr)
        delete _depthFrame;
    
    _depthFrame = frame;
}

PAEDeviceStatus PhysicalDevice::getStatus() {
    PAEDeviceStatus status;
    strcpy(status.deviceName, _name.c_str());
    strcpy(status.deviceSerial, _serial.c_str());
    status.state = _state;
    
    status.userCount = (unsigned int) _usersTracker._users.size();
    status.trackedUsers = _usersTracker.getUsers();

    // If live view is enabled, update the window fo the device
    if(_pae->isLiveViewEnabled()) {
        updateLiveView(status);
    }

    return status;
}

void PhysicalDevice::updateLiveView(const PAEDeviceStatus &status) {
    if(_state == DeviceState::DEVICE_ACTIVE && _colorFrame != nullptr) {
        if(_colorFrame->getData() != NULL) {
            cv::Mat cImageBGR;
            const cv::Mat mImageRGB(_colorFrame->getHeight(),
                                    _colorFrame->getWidth(),
                                    CV_8UC3,
                                    (void*)_colorFrame->getData());

            cv::cvtColor(mImageRGB, cImageBGR, cv::COLOR_RGB2BGR);

            for(int i = 0; i < status.userCount; ++i) {
                if(status.trackedUsers[i].state != USER_TRACKED) {
                    continue;
                }

                Joint aJoints[15];
                aJoints[ 0] = status.trackedUsers[i].skeleton.head;
                aJoints[ 1] = status.trackedUsers[i].skeleton.neck;
                aJoints[ 2] = status.trackedUsers[i].skeleton.leftShoulder;
                aJoints[ 3] = status.trackedUsers[i].skeleton.rightShoulder;
                aJoints[ 4] = status.trackedUsers[i].skeleton.leftElbow;
                aJoints[ 5] = status.trackedUsers[i].skeleton.rightElbow;
                aJoints[ 6] = status.trackedUsers[i].skeleton.leftHand;
                aJoints[ 7] = status.trackedUsers[i].skeleton.rightHand;
                aJoints[ 8] = status.trackedUsers[i].skeleton.torso;
                aJoints[ 9] = status.trackedUsers[i].skeleton.leftHip;
                aJoints[10] = status.trackedUsers[i].skeleton.rightHip;
                aJoints[11] = status.trackedUsers[i].skeleton.leftKnee;
                aJoints[12] = status.trackedUsers[i].skeleton.rightKnee;
                aJoints[13] = status.trackedUsers[i].skeleton.leftFoot;
                aJoints[14] = status.trackedUsers[i].skeleton.rightFoot;

                cv::Point2f aPoint[15];
                for( int s = 0; s < 15; ++ s )
                {
                    const simd_float3& rPos = aJoints[s].position;
                    _rigTracker.convertJointCoordinatesToDepth(
                                                               rPos.x, rPos.y, rPos.z,
                                                               &(aPoint[s].x), &(aPoint[s].y) );


                    aPoint[s].x = cImageBGR.cols - aPoint[s].x;
                }

                cv::line(cImageBGR, aPoint[ 0], aPoint[ 1], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 1], aPoint[ 2], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 1], aPoint[ 3], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 2], aPoint[ 4], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 3], aPoint[ 5], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 4], aPoint[ 6], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 5], aPoint[ 7], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 1], aPoint[ 8], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 8], aPoint[ 9], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 8], aPoint[10], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[ 9], aPoint[11], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[10], aPoint[12], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[11], aPoint[13], cv::Scalar( 255, 0, 0 ), 3 );
                cv::line(cImageBGR, aPoint[12], aPoint[14], cv::Scalar( 255, 0, 0 ), 3 );

                for(int s = 0; s < 15; ++s)
                {
                    if(aJoints[s].positionConfidence < 0.5 )
                        cv::circle(cImageBGR, aPoint[s], 3, cv::Scalar(0, 0, 255), 2);
                    else
                        cv::circle(cImageBGR, aPoint[s], 3, cv::Scalar(0, 255, 0), 2);
                }
            }

            cv::imshow(_serial, cImageBGR );
        }
    }
}


PhysicalDevice::~PhysicalDevice() {
    // Start by making sure the device is idle
    setIdle();
    
    // There is nothing to free if the device wasn't connected
    if(_state == DeviceState::DEVICE_IDLE) {
        return;
    }
    
    // Mark the device as closing
    _state = DeviceState::DEVICE_CLOSING;
    
    // Properly free resources
    _colorStream.destroy();
    _depthStream.destroy();
    
    delete _colorFrame;
    delete _depthFrame;
    
    _device.close();
}
