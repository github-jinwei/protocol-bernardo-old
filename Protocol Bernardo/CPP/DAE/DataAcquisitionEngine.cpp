//
//  DataAcquisitionEngine.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "DataAcquisitionEngine.hpp"
#include <iostream>
#include <cstdlib>
#include <signal.h>
#include <opencv2/opencv.hpp>


void DataAcquisitionEngine::main() {
    //Start by setting up the log level
    libfreenect2::setGlobalLogger(
        libfreenect2::createConsoleLogger(
            libfreenect2::Logger::Debug
        )
    );
    
    // Execute a first parse
    parseForKinects();
    
    cv::Mat rgbmat, depthmat, depthmatUndistorted, irmat, rgbd, rgbd2;
    
    // And now start the loop
    while (_running) {
        for (std::pair<std::string, Kinect *> kinectReference : _kinects) {
            Kinect * kinect = kinectReference.second;
            libfreenect2::FrameMap * frames;
            
            // Make sure we are not handlign a kinect being loaded/offloaded
            if(kinect == NULL)
                continue;
            
            frames = kinect->getFrames();
            
            // Sometimes there is no frames
            if(frames == nullptr)
                continue;
            
            // Do something with the frames
            std::cout << "Has frames" << std::endl;
            
            // Get the frames
//            libfreenect2::Frame *rgb = (*frames)[libfreenect2::Frame::Color];
//            libfreenect2::Frame *ir = (*frames)[libfreenect2::Frame::Ir];
//            libfreenect2::Frame *depth = (*frames)[libfreenect2::Frame::Depth];
//
//            cv::Mat(rgb->height, rgb->width, CV_8UC4, rgb->data).copyTo(rgbmat);
//            cv::Mat(ir->height, ir->width, CV_32FC1, ir->data).copyTo(irmat);
//            cv::Mat(depth->height, depth->width, CV_32FC1, depth->data).copyTo(depthmat);
            
            
            kinect->freeFrames(*frames);
        }
    }
    
    // The loop has ended, we are closing the DAE.
}

void DataAcquisitionEngine::parseForKinects() {
    // Do we have any device ?
    int availableDevices = _freenect2.enumerateDevices();
    if(availableDevices == 0)
    {
        std::cout << "no device connected!" << std::endl;
    }
    
    std::vector<std::string> foundSerials;
    
    // Iterate on each device
    for(int i = 0; i < availableDevices; ++i) {
        // Get its serial
        std::string serial = _freenect2.getDeviceSerialNumber(i);
        foundSerials.push_back(serial);
        
        // Is this device already registered ?
        if(_kinects.count(serial) == 1)
            continue; // Kinect already registered
        
        // Let's register it
        Kinect * kinect = new Kinect(serial);
        _kinects[serial] = kinect;
    }
    
    // Now, check for missing kinects
    for(auto it = _kinects.cbegin(); it != _kinects.cend();) {
        // Was the kinect serial found when parsing ?
        if(std::find(foundSerials.begin(), foundSerials.end(), it->first) != foundSerials.end()) {
            ++it;
            continue; // Kinect connected
        }
        
        // Kinect is no longer here, remove it
        delete it->second;
        _kinects.erase(it++);
    }
    
    std::cout << _kinects.size() << std::endl;
}

void DataAcquisitionEngine::connectToKinect(const std::string &serial) {
    // Make sure the kinect specified is available
    if(_kinects.count(serial) == 0)
        return; // Do nothing
    
    _kinects[serial]->connect(&_freenect2);
}

void DataAcquisitionEngine::setKinectActive(const std::string &serial) {
    // Make sure the kinect specified is available
    if(_kinects.count(serial) == 0)
        return; // Do nothing
    
    _kinects[serial]->setActive();
}

void DataAcquisitionEngine::setKinectIdle(const std::string &serial) {
    // Make sure the kinect specified is available
    if(_kinects.count(serial) == 0)
        return; // Do nothing
    
    _kinects[serial]->setIdle();
}

DAEStatus * DataAcquisitionEngine::getStatus() {
    DAEStatus * status = new DAEStatus();
    
    status->kinectCount = (unsigned int)_kinects.size();
    
    // Allocate space to store the kinect states (C-style baby)
    status->_kinectStatus = (KinectStatus *)malloc(sizeof(KinectStatus) * status->kinectCount);
    
    int i = 0;
    for (std::pair<std::string, Kinect *> kinectReference : _kinects) {
        Kinect * kinect = kinectReference.second;
        status->_kinectStatus[i] = kinect->getState();
        ++i;
    }
    
    return status;
}

DataAcquisitionEngine::~DataAcquisitionEngine() {
    _running = false;
    
    // Let's free all the kinect
    for (std::pair<std::string, Kinect *> kinectReference : _kinects) {
        Kinect * kinect = kinectReference.second;
        delete kinect;
    }
}

//
//void DataAcquisitionEngine::startAcquisition() {
//    // Begin streaming from the device
//    if(!device->startStreams(false, true)) {
//        _status->state = DAEState::ERROR;
//        return;
//    }
//
//    // Print connected device informations
////    std::cout << "device serial: " << device->getSerialNumber() << std::endl;
////    std::cout << "device firmware: " << device->getFirmwareVersion() << std::endl;
//
//    libfreenect2::FrameMap frames;
//
////    libfreenect2::Registration* registration = new libfreenect2::Registration(device->getIrCameraParams(), device->getColorCameraParams());
////    libfreenect2::Frame undistorted(512, 424, 4), registered(512, 424, 4);
//
//    _status->state = DAEState::ACQUIRING;
//
//    while(_status->state == DAEState::ACQUIRING)
//    {
//        if (!listener->waitForNewFrame(frames, 10 * 1000)) // 10 sconds
//        {
//            std::cout << "timeout!" << std::endl;
//            return;
//        }
//
//        std::cout << "Frames received" << std::endl;
//
////        libfreenect2::Frame * rgb = frames[libfreenect2::Frame::Color];
//        libfreenect2::Frame * ir = frames[libfreenect2::Frame::Ir];
//        libfreenect2::Frame * depth = frames[libfreenect2::Frame::Depth];
//
////        registration->apply(rgb, depth, &undistorted, &registered);
//
//        listener->release(frames);
//    }
//
//    device->stop();
//}
