//
//  Kinect.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "Kinect.hpp"

void Kinect::connect() {
    _state = KinectState::CONNECTING;
    
    // Open the device
    if (_device.open(_uri.c_str()) != openni::STATUS_OK)
    {
        printf("Coudle not open the device:\n%s\n", openni::OpenNI::getExtendedError());
        _state = KinectState::ERROR;
        return;
    }
    
    // ////////////////////////
    // Create the color stream
    if(_colorStream.create(_device, openni::SENSOR_COLOR) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = KinectState::ERROR;
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
    
    
    // ////////////////////////
    // Create the depth stream
    
    if(_depthStream.create(_device, openni::SENSOR_DEPTH) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = KinectState::ERROR;
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
    
    // Mark the kinect as ready
    _state = KinectState::READY;
}

void Kinect::setActive() {
    // Do nothing if the kinect is not ready to stream
    if(_state != KinectState::READY)
        return;

    // Start the streams
    if(_colorStream.start() != openni::STATUS_OK) {
        _state = KinectState::ERROR;
        return;
    }
    
    if(_depthStream.start() != openni::STATUS_OK) {
        _state = KinectState::ERROR;
        return;
    }
    
    _state = KinectState::ACTIVE;
}

void Kinect::setIdle() {
    if(_state == KinectState::ACTIVE) {
        _colorStream.stop();
        _depthStream.stop();
        _state = KinectState::READY;
    }
}

void Kinect::storeColorFrame(openni::VideoFrameRef *frame) {
    if(_colorFrame != nullptr)
        delete _colorFrame;
    
    _colorFrame = frame;
}

void Kinect::storeDepthFrame(openni::VideoFrameRef *frame) {
    if(_depthFrame != nullptr)
        delete _depthFrame;
    
    _depthFrame = frame;
}

KinectStatus Kinect::getState() {
    KinectStatus status;
    strcpy(status._serial, _serial.c_str());
    status.state = _state;
    
    return status;
}


Kinect::~Kinect() {
    // Start by making sure the kinect is idle
    setIdle();
    
    // There is nothing to free if the kinect wasn't connected
    if(_state == KinectState::IDLE) {
        return;
    }
    
    // Mark the kinect as closing
    _state = KinectState::CLOSING;
    
    // Properly free resources
    _colorStream.destroy();
    _depthStream.destroy();
    
    delete _colorFrame;
    delete _depthFrame;
    
    _device.close();
}
