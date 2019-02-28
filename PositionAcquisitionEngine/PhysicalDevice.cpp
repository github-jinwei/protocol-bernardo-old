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

DAEDeviceStatus PhysicalDevice::getStatus() {
    DAEDeviceStatus status;
    strcpy(status.deviceName, _name.c_str());
    strcpy(status.deviceSerial, _serial.c_str());
    status.state = _state;
    
    status.userCount = (unsigned int) _usersTracker._users.size();
    status.trackedUsers = _usersTracker.getUsers();

    // If live view is enabled, update the window fo the device
    if(_pae->isLiveViewEnabled()) {
        if(_state == DeviceState::DEVICE_ACTIVE && _colorFrame != nullptr) {
            if(_colorFrame->getData() != NULL) {
                std::cout << "Frame size " << _colorFrame->getDataSize() << std::endl;

                cv::Mat cImageBGR;
                const cv::Mat mImageRGB(_colorFrame->getHeight(),
                                        _colorFrame->getWidth(),
                                        CV_8UC3,
                                        (void*)_colorFrame->getData());

                // p2c. convert form RGB to BGR
                cv::cvtColor(mImageRGB, cImageBGR, cv::COLOR_RGB2BGR);

                cv::imshow(_serial, cImageBGR );
            }
        }
    }

    return status;
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
