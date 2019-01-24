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
#include <nite2/NiTE.h>

DataAcquisitionEngine * DataAcquisitionEngine::_instance;
bool DataAcquisitionEngine::_openNIInitialized = false;

void DataAcquisitionEngine::main() {
    // Init OpenNI
    
    if(!DataAcquisitionEngine::_openNIInitialized) {
        openni::OpenNI::initialize();
        DataAcquisitionEngine::_openNIInitialized = true;
    }
    
    std::string initMessage(openni::OpenNI::getExtendedError());
    
    if(initMessage.size() > 0) {
        // An error occured while initializing OpenNI
        std::cout << initMessage << std::endl;
        throw "Could not itialize OpenNI";
    }
    
    nite::Status status = nite::NiTE::initialize();
    if(status != nite::STATUS_OK)
        std::cout << "NiTE Error" << std::endl;
    else
        std::cout << "NiTE Init OK" << std::endl;
    
    // Execute a first parse
    parseForDevices();

    // And now start the loop
//    while (_running) {
//        for (std::pair<std::string, Device *> deviceReference : _devices) {
//            Device * device = deviceReference.second;
//            
//            // Make sure we are not handlign a devicebeing loaded/offloaded
//            if(device == NULL)
//                continue;
//            
//            device->readUserFrame();
//        }
//        
//        unsigned int microseconds = 250;
//        usleep(microseconds);
//    }
    
    // The loop has ended, we are closing the DAE.
}

void DataAcquisitionEngine::parseForDevices() {
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
            // Serial already stored, ignore device
            continue;
        }
        
        // Mark the device as found and register it
        foundSerials.push_back(serial);
        Device * device = new Device(availableDevices[i], serial);
        _devices[serial] = device;
    }
    
    // Now, check for missing devices
    for(auto it = _devices.cbegin(); it != _devices.cend();) {
        // Was the device serial found when parsing ?
        if(std::find(foundSerials.begin(), foundSerials.end(), it->first) != foundSerials.end()) {
            ++it;
            continue; // Device connected
        }

        // Device is no longer here, remove it
        delete it->second;
        _devices.erase(it++);
    }
}

void DataAcquisitionEngine::connectToDevice(const std::string &serial) {
    // Make sure the device specified is available
    if(_devices.count(serial) == 0)
        return; // Do nothing
    
    _devices[serial]->connect();
}

void DataAcquisitionEngine::setDeviceActive(const std::string &serial) {
    // Make sure the device specified is available
    if(_devices.count(serial) == 0)
        return; // Do nothing
    
    _devices[serial]->setActive();
}

void DataAcquisitionEngine::setDeviceIdle(const std::string &serial) {
    // Make sure the device specified is available
    if(_devices.count(serial) == 0)
        return; // Do nothing
    
    _devices[serial]->setIdle();
}

DAEStatus * DataAcquisitionEngine::getStatus() {
    DAEStatus * status = new DAEStatus();
    
    status->deviceCount = (unsigned int)_devices.size();
    
    // Allocate space to store the device states (C-style baby)
    status->_deviceStatus = (DeviceStatus *)malloc(sizeof(DeviceStatus) * status->deviceCount);
    
    int i = 0;
    for (std::pair<std::string, Device *> deviceReference : _devices) {
        Device * device = deviceReference.second;
        status->_deviceStatus[i] = device->getState();
        ++i;
    }
    
    return status;
}

DataAcquisitionEngine::~DataAcquisitionEngine() {
    _running = false;

    // Let's free all the devices
    for (std::pair<std::string, Device *> deviceReference : _devices) {
        Device * device = deviceReference.second;
        delete device;
    }
    
    nite::NiTE::shutdown();
}
