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

#include "../App.hpp"

DataAcquisitionEngine * DataAcquisitionEngine::_instance;
bool DataAcquisitionEngine::_openNIInitialized = false;

void DataAcquisitionEngine::start() {
    // Init OpenNI
    if(!DataAcquisitionEngine::_openNIInitialized) {
        if(openni::OpenNI::initialize() != openni::STATUS_OK) {
            std::cout << openni::OpenNI::getExtendedError() << std::endl;
            throw "Could not itialize OpenNI";
        }
        
        DataAcquisitionEngine::_openNIInitialized = true;
    }
    
    // Init NiTE
    if(nite::NiTE::initialize() != nite::STATUS_OK) {
        throw "Could not itialize NiTE";
    }
    
    // Execute a first parse
    parseForDevices();
}

void DataAcquisitionEngine::stop() {
    // Let's free all the devices
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        delete device;
    }
    
    _devices.clear();
    
    // Stop NiTE
    nite::NiTE::shutdown();
}

void DataAcquisitionEngine::parseForDevices() {
    std::cout << "Parsing" << std::endl;
    // Get all the available devices
    openni::Array<openni::DeviceInfo> availableDevices;
    openni::OpenNI::enumerateDevices(&availableDevices);
    
    // `foundSerial` is used to track found devices, and match against
    // currently loaded ones to track disconnections
    std::vector<std::string> foundSerials;
    
    // The serial extraction regex.
    // URI to the devices holds a serial parameter. We are using this
    // regex to extract it, allowing for unique identifications of the kinects
    std::regex regex("serial=(.*?)(&.*)?$");
    
    // Parse all the detected devices
    for (int i = 0; i < availableDevices.getSize(); ++i) {
        // Get the device URI
        const std::string uri(availableDevices[i].getUri());
        
        // Extract its serial
        std::smatch match;
        if (!std::regex_search(uri.begin(), uri.end(), match, regex)) {
            // Could not extract a serial, skip the device
            std::cout << "Could not get serial for device : " << uri << std::endl;
            continue;
        }
        std::string serial = match[1];
        
        // Check the serial isn't already stored
        if(std::find(foundSerials.begin(), foundSerials.end(), serial) != foundSerials.end()) {
            // Serial already stored, ignore device
            continue;
        }
        
        // Mark the device as found and register it
        foundSerials.push_back(serial);
        PhysicalDevice * device = new PhysicalDevice(availableDevices[i], serial);
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
    
    // For each device currently stored, generate and store its status
    int i = 0;
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        status->_deviceStatus[i] = device->getStatus();
        ++i;
    }
    
    return status;
}

DataAcquisitionEngine::~DataAcquisitionEngine() {
    stop();
    
    // Ideally, stop OpenNI too, but this is causing a EXC_BAD_ACCESS,
    // so we will not do it for now...
}


// C Access

void DAEPrepare() {
    App->dae = DataAcquisitionEngine::getInstance();
    App->dae->start();
}

void DAEParseForDevices() {
    App->dae->parseForDevices();
}

void DAEConnectToDevice(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->connectToDevice(serial);
}

void DAESetDeviceActive(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->setDeviceActive(serial);
}

void DAESetDeviceIdle(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->setDeviceIdle(serial);
}

void DAEEndAcquisition() {
    App->dae->stop();
}

DAEStatus * DAEGetStatus() {
    return App->dae->getStatus();
}
