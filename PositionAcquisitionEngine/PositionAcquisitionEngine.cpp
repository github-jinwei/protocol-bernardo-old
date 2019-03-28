//
//  PositionAcquisitionEngine.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PositionAcquisitionEngine.hpp"
#include "PhysicalDevice.hpp"

PositionAcquisitionEngine * PositionAcquisitionEngine::_instance;
bool PositionAcquisitionEngine::_openNIInitialized = false;

PositionAcquisitionEngine::PositionAcquisitionEngine() {
    hostname[_POSIX_HOST_NAME_MAX] = '\0';
    gethostname(hostname, _POSIX_HOST_NAME_MAX);
}

void PositionAcquisitionEngine::enableLiveView() {
    if(PositionAcquisitionEngine::_openNIInitialized) {
        return;
    }

    _liveView = true;
}

void PositionAcquisitionEngine::disableLiveView() {
    _liveView = false;
}

void PositionAcquisitionEngine::start() {
    if(_isRunning) { return; }

    _isRunning = true;

    // Init OpenNI
    if(!PositionAcquisitionEngine::_openNIInitialized) {
        if(openni::OpenNI::initialize() != openni::STATUS_OK) {
            std::cout << openni::OpenNI::getExtendedError() << std::endl;
            throw "Could not itialize OpenNI";
        }
        
        PositionAcquisitionEngine::_openNIInitialized = true;
    }
    
    // Add our event listeners to OpenNI
    _connectionListener.pae = this;
    _disconnectionListener.pae = this;
    
    openni::OpenNI::addDeviceConnectedListener(&_connectionListener);
    openni::OpenNI::addDeviceDisconnectedListener(&_disconnectionListener);
    
    // Init NiTE
    if(nite::NiTE::initialize() != nite::STATUS_OK) {
        throw "Could not itialize NiTE";
    }
    
    // Execute a first parse
    parseForDevices();
}

void PositionAcquisitionEngine::stop() {
    if(!_isRunning) { return; }

    // Stop NiTE
    nite::NiTE::shutdown();

    _devices.clear();

    // Let's free all the devices
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        delete device;
        device = nullptr;
    }

    _isRunning = false;
}

void PositionAcquisitionEngine::parseForDevices() {
    // Get all the available devices
    openni::Array<openni::DeviceInfo> availableDevices;
    openni::OpenNI::enumerateDevices(&availableDevices);
    
    // Parse all the detected devices
    for (int i = 0; i < availableDevices.getSize(); ++i) {
        onNewDevice(&availableDevices[i]);
    }
}

void PositionAcquisitionEngine::onNewDevice(const openni::DeviceInfo * deviceInfo) {
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
    PhysicalDevice * device = new PhysicalDevice(*deviceInfo, serial, this);
    _devices[serial] = device;
}

void PositionAcquisitionEngine::onDeviceDisconnected(const openni::DeviceInfo * deviceInfo) {
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

void PositionAcquisitionEngine::connectAllDevices() {
    for(auto const &device: _devices) {
        connectToDevice(device.second->getSerial());
    }
}

void PositionAcquisitionEngine::connectToDevice(const std::string &serial) {
    // Make sure the device specified is available
    if(_devices.count(serial) == 0)
        return; // Do nothing
    
    _devices[serial]->connect();
}

void PositionAcquisitionEngine::activateAllDevices() {
    for(auto const &device: _devices) {
        setDeviceActive(device.second->getSerial());
    }
}

void PositionAcquisitionEngine::setDeviceActive(const std::string &serial) {
    // Make sure the device specified is available
    if(_devices.count(serial) == 0)
        return; // Do nothing
    
    _devices[serial]->setActive();
}

void PositionAcquisitionEngine::deactivateAllDevices() {
    for(auto const &device: _devices) {
        setDeviceIdle(device.second->getSerial());
    }
}

void PositionAcquisitionEngine::setDeviceIdle(const std::string &serial) {
    // Make sure the device specified is available
    if(_devices.count(serial) == 0)
        return; // Do nothing
    
    _devices[serial]->setIdle();
}

PAEStatus * PositionAcquisitionEngine::getStatus() {
    PAEStatus * status = new PAEStatus();
    
    status->deviceCount = (unsigned int)_devices.size();
    
    // Allocate space to store the device states (C-style baby)
    status->connectedDevices = (PAEDeviceStatus *)malloc(sizeof(PAEDeviceStatus) * status->deviceCount);
    
    // For each device currently stored, generate and store its status
    int i = 0;
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        status->connectedDevices[i] = device->getStatus();
        memcpy(status->connectedDevices[i].deviceHostname, hostname, _POSIX_HOST_NAME_MAX);
        ++i;
    }

    // Emit the status if needed
    if (_isEmitter) {
        _linker.send(status);
    }


	// Wait for the linker to finish its work and lock it
	_linker.receiverLock.lock();

    // Integrate the status stored in the linker
    std::vector<PAEDeviceStatus> foreignDevices = _linker.storedDevices();

    unsigned int oldSize = status->deviceCount;
    status->deviceCount += (unsigned int)foreignDevices.size();

    status->connectedDevices = (PAEDeviceStatus *)realloc(status->connectedDevices, sizeof(PAEDeviceStatus) * status->deviceCount);

    for(PAEDeviceStatus device: foreignDevices) {
		// We copy each device content to uniformize treatments afterward
        status->connectedDevices[oldSize] = PAEDeviceStatus_copy(device);
        oldSize++;
    }

	// Unlock the linker
	_linker.receiverLock.unlock();
    
    return status;
}

void PositionAcquisitionEngine::freeStatus(PAEStatus * status) {
    for(int i = 0; i < status->deviceCount; ++i) {
        delete status->connectedDevices[i].trackedUsers;
        status->connectedDevices[i].trackedUsers = nullptr;
    }

    delete status->connectedDevices;
    status->connectedDevices = nullptr;

    delete status;
    status = nullptr;
}

PositionAcquisitionEngine::~PositionAcquisitionEngine() {
    stop();
    
    // Ideally, stop OpenNI too, but this may cause a EXC_BAD_ACCESS,
    // so we will not do it for now... but for now we are doing it.
    openni::OpenNI::shutdown();
}

std::string PositionAcquisitionEngine::getDeviceSerial(const openni::DeviceInfo * deviceInfo) {
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
