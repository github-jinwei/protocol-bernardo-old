//
//  Kinect.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "Kinect.hpp"

void Kinect::connect(libfreenect2::Freenect2 * freenect2) {
    _state = KinectState::CONNECTING;
    
    _pipeline = new libfreenect2::OpenCLPacketPipeline();
    _device = freenect2->openDevice(_serial, _pipeline);
    
    int frameTypes = 0 | libfreenect2::Frame::Color |
                         libfreenect2::Frame::Ir    |
                         libfreenect2::Frame::Depth;
    
    _listener = new libfreenect2::SyncMultiFrameListener(frameTypes);
    _device->setColorFrameListener(_listener);
    _device->setIrAndDepthFrameListener(_listener);
    
    _state = KinectState::READY;
}

void Kinect::setActive() {
    // Do nothing if the kinect is not ready to stream
    if(_state != KinectState::READY)
        return;
    
    // Start streaming
    int success = _device->start();
    
    // Update the kinect status accordingly
    _state = success ? KinectState::ACTIVE : KinectState::ERROR;
}

void Kinect::setIdle() {
    // Make sure we only pause an active Kinect
    if(_state == KinectState::ACTIVE) {
        _device->stop();
        _state = KinectState::READY;
    }
}

libfreenect2::FrameMap * Kinect::getFrames() {
    // Are we in an active state
    if(_state != KinectState::ACTIVE)
        return nullptr;
    
    // Do we have any frame ?
    if(!_listener->hasNewFrame())
        return nullptr;
    
    libfreenect2::FrameMap * frames = new libfreenect2::FrameMap();
    _listener->waitForNewFrame(*frames);
    
    return frames;
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
    
    _state = KinectState::CLOSING;
    
    // Close the connection
    _device->close();
    
    // Free what needs to be
    delete _listener;
    delete _device;
    // Pipeline deleted by the device directly
}
