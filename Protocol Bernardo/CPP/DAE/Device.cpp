//
//  Device.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "Device.hpp"
#include <opencv2/opencv.hpp>

void Device::connect() {
    _state = DeviceState::CONNECTING;
    
    // Open the device
    if (_device.open(_uri.c_str()) != openni::STATUS_OK)
    {
        printf("Coudle not open the device:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::ERROR;
        return;
    }
    
    _device.setDepthColorSyncEnabled(true);
    
    // ////////////////////////
    // Create the color stream
    if(_colorStream.create(_device, openni::SENSOR_COLOR) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::ERROR;
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
        _state = DeviceState::ERROR;
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
    _userTracker.create(&_device);
    _userTracker.setSkeletonSmoothingFactor(.0f);
    _userFrameListener.device = this;
    _userTracker.addNewFrameListener(&_userFrameListener);
    
    // Mark the device as ready
    _state = DeviceState::READY;
    
//    cv::namedWindow( "User Image",  cv::WINDOW_AUTOSIZE );
}

void Device::setActive() {
    // Do nothing if the device is not ready to stream
    if(_state != DeviceState::READY)
        return;

    // Start the streams
    if(_colorStream.start() != openni::STATUS_OK) {
        _state = DeviceState::ERROR;
        return;
    }
    
    if(_depthStream.start() != openni::STATUS_OK) {
        _state = DeviceState::ERROR;
        return;
    }
    
    _state = DeviceState::ACTIVE;
}

void Device::setIdle() {
    if(_state == DeviceState::ACTIVE) {
        _colorStream.stop();
        _depthStream.stop();
        _state = DeviceState::READY;
    }
}

void Device::storeColorFrame(openni::VideoFrameRef *frame) {
    if(_colorFrame != nullptr)
        delete _colorFrame;
    
    _colorFrame = frame;
}

void Device::storeDepthFrame(openni::VideoFrameRef *frame) {
    if(_depthFrame != nullptr)
        delete _depthFrame;
    
    _depthFrame = frame;
}

void Device::readUserFrame() {
    if(_state != DeviceState::ACTIVE)
        return;
}

void Device::onUserFrame(nite::UserTrackerFrameRef *userFrame) {
    _userFrame = userFrame;
    
    const nite::Array<nite::UserData>& users = _userFrame->getUsers();
    for( int i = 0; i < users.getSize(); ++ i )
    {
        if(users[i].isNew()) {
            std::cout << "Started tracking User #" << i << std::endl;
            _userTracker.startSkeletonTracking(i);
            continue;
        }
        
        if(!users[i].isLost()) {
            std::cout << "Stopped tracking User #" << i << std::endl;
            _userTracker.stopSkeletonTracking(i);
            continue;
        }
        
        nite::Skeleton skeleton = users[i].getSkeleton();
        std::cout << "HEADX " << skeleton.getJoint(nite::JOINT_HEAD).getPosition().x << std::endl;
    }
}

DeviceStatus Device::getState() {
    DeviceStatus status;
    strcpy(status._name, _name.c_str());
    strcpy(status._serial, _serial.c_str());
    status.state = _state;
    
    return status;
}


Device::~Device() {
    // Start by making sure the device is idle
    setIdle();
    
    // There is nothing to free if the device wasn't connected
    if(_state == DeviceState::IDLE) {
        return;
    }
    
    // Mark the device as closing
    _state = DeviceState::CLOSING;
    
    // Properly free resources
    _colorStream.destroy();
    _depthStream.destroy();
    
    delete _colorFrame;
    delete _depthFrame;
    
    _device.close();
}
