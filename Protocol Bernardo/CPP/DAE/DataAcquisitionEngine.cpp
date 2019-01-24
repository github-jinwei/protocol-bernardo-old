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
#include <regex>
#include <string>

#include <ni2/OpenNI.h>

DataAcquisitionEngine * DataAcquisitionEngine::_instance;

void DataAcquisitionEngine::main() {
    // Init OpenNI
    openni::OpenNI::initialize();
    std::string initMessage(openni::OpenNI::getExtendedError());
    
    if(initMessage.size() > 0) {
        // An error occured while initializing OpenNI
        std::cout << initMessage << std::endl;
        throw "Could not itialize OpenNI";
    }
    
    // Execute a first parse
    parseForKinects();

    // And now start the loop
    while (_running) {
        for (std::pair<std::string, Kinect *> kinectReference : _kinects) {
            Kinect * kinect = kinectReference.second;
            
            // Make sure we are not handlign a kinect being loaded/offloaded
            if(kinect == NULL)
                continue;
            
            
        }
        
        unsigned int microseconds = 250;
        usleep(microseconds);
    }
    
    // The loop has ended, we are closing the DAE.
}

void DataAcquisitionEngine::parseForKinects() {
    // Get all available devices
    openni::Array<openni::DeviceInfo> availableDevices;
    openni::OpenNI::enumerateDevices(&availableDevices);
    
    std::vector<std::string> foundSerials;
    
    // The serial extraction regex
    std::regex regex("serial=(.*?)&");
    
    for (int i = 0; i < availableDevices.getSize(); ++i) {
        // Get the device URI
        const std::string uri(availableDevices[i].getUri());
        
        // Extract its serial
        std::smatch match;
        if (!std::regex_search(uri.begin(), uri.end(), match, regex))
            continue;
        std::string serial = match[1];
        
        // Check the serial isn't already stored
        if(std::find(foundSerials.begin(), foundSerials.end(), serial) != foundSerials.end()) {
            // Serial already stored, ignore kinect
            continue;
        }
        
        std::cout << availableDevices[i].getUri() << std::endl;
        
        // Mark the device as found and register it
        foundSerials.push_back(serial);
        Kinect * kinect = new Kinect(availableDevices[i], serial);
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
}

void DataAcquisitionEngine::connectToKinect(const std::string &serial) {
    // Make sure the kinect specified is available
    if(_kinects.count(serial) == 0)
        return; // Do nothing
    
    _kinects[serial]->connect();
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
    
    // Let's free all the devices
    for (std::pair<std::string, Kinect *> kinectReference : _kinects) {
        Kinect * kinect = kinectReference.second;
        delete kinect;
    }
}
