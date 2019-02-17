//
//  DataAcquisitionEngine.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include <iostream>
#include <regex>
#include <string>

#include <ni2/OpenNI.h>
#include <nite2/NiTE.h>

#include "DataAcquisitionEngine.hpp"

#include "../App.hpp"
#include "PhysicalDevice.hpp"

DataAcquisitionEngine * DataAcquisitionEngine::_instance;
bool DataAcquisitionEngine::_openNIInitialized = false;

DataAcquisitionEngine::DataAcquisitionEngine() {
    hostname[_POSIX_HOST_NAME_MAX] = '\0';
    gethostname(hostname, _POSIX_HOST_NAME_MAX);
}

void DataAcquisitionEngine::enableLiveView() {
    if(DataAcquisitionEngine::_openNIInitialized) {
        return;
    }

    _liveView = true;
}

void DataAcquisitionEngine::disableLiveView() {
    _liveView = false;
}

void DataAcquisitionEngine::start() {
    // Init OpenNI
    if(!DataAcquisitionEngine::_openNIInitialized) {
        if(openni::OpenNI::initialize() != openni::STATUS_OK) {
            std::cout << openni::OpenNI::getExtendedError() << std::endl;
            throw "Could not itialize OpenNI";
        }
        
        DataAcquisitionEngine::_openNIInitialized = true;
    }
    
    // Add our event listeners to OpenNI
    _connectionListener.dae = this;
    _disconnectionListener.dae = this;
    
    openni::OpenNI::addDeviceConnectedListener(&_connectionListener);
    openni::OpenNI::addDeviceDisconnectedListener(&_disconnectionListener);
    
    // Init NiTE
    if(nite::NiTE::initialize() != nite::STATUS_OK) {
        throw "Could not itialize NiTE";
    }
    
    // Execute a first parse
    parseForDevices();
}

void DataAcquisitionEngine::stop() {
    // Stop NiTE
    nite::NiTE::shutdown();

    _devices.clear();

    // Let's free all the devices
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        delete device;
    }

}

void DataAcquisitionEngine::parseForDevices() {
    // Get all the available devices
    openni::Array<openni::DeviceInfo> availableDevices;
    openni::OpenNI::enumerateDevices(&availableDevices);
    
    // Parse all the detected devices
    for (int i = 0; i < availableDevices.getSize(); ++i) {
        onNewDevice(&availableDevices[i]);
    }
}

void DataAcquisitionEngine::onNewDevice(const openni::DeviceInfo * deviceInfo) {
    // Get the device serial
    std::string serial = getDeviceSerial(deviceInfo);
    
    // Check the serial isn't empty
    if(serial.size() == 0) {
        return;
    }
    
    // Check the serial isn't already stored
    if(_devices.find(serial) != _devices.end()) {
        // Serial already stored, ignore device
        return;
    }
    
    // Register the device
    PhysicalDevice * device = new PhysicalDevice(*deviceInfo, serial);
    _devices[serial] = device;
}

void DataAcquisitionEngine::onDeviceDisconnected(const openni::DeviceInfo * deviceInfo) {
    // Get the device serial
    std::string serial = getDeviceSerial(deviceInfo);
    
    // Check the serial isn't empty
    if(serial.size() == 0) {
        return;
    }
    
    // Erase and remove the device from the list
    delete _devices[serial];
    _devices.erase(serial);
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
    status->_deviceStatus = (DAEDeviceStatus *)malloc(sizeof(DAEDeviceStatus) * status->deviceCount);
    
    // For each device currently stored, generate and store its status
    int i = 0;
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        status->_deviceStatus[i] = device->getStatus();
        memcpy(status->_deviceStatus[i]._hostname, hostname, _POSIX_HOST_NAME_MAX);
        ++i;
    }
    
    return status;
}

DataAcquisitionEngine::~DataAcquisitionEngine() {
    stop();
    
    // Ideally, stop OpenNI too, but this is causing a EXC_BAD_ACCESS,
    // so we will not do it for now...
}

std::string DataAcquisitionEngine::getDeviceSerial(const openni::DeviceInfo * deviceInfo) {
    // Get the device URI
    const std::string uri(deviceInfo->getUri());
    
    // The serial extraction regex.
    // URI to the devices holds a serial parameter. We are using this
    // regex to extract it, allowing for unique identifications of the kinects
    std::regex regex("serial=(.*?)(&.*)?$");
    
    // Extract its serial
    std::smatch match;
    if (!std::regex_search(uri.begin(), uri.end(), match, regex)) {
        // Could not extract a serial, skip the device
        std::cout << "Could not get serial for device : " << uri << std::endl;
        return "";
    }
    
    // mathc[1] is the serial
    return match[1];
}


// C Access

void DAEEnableLiveView() {
    App->dae->enableLiveView();
}

void DAEDisableLiveView() {
    App->dae->disableLiveView();
}

void DAEPrepare() {
    App->dae->start();
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
