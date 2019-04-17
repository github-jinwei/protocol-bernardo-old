//
//  PositionAcquisitionEngine.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include <iostream>
#include <regex>

#include "PositionAcquisitionEngine.hpp"
#include "PhysicalDevice.hpp"
#include "Utils/LiveViewer.hpp"

PositionAcquisitionEngine * PositionAcquisitionEngine::_instance;

PositionAcquisitionEngine::PositionAcquisitionEngine() {
    hostname[_POSIX_HOST_NAME_MAX] = '\0';
    gethostname(hostname, _POSIX_HOST_NAME_MAX);

	_linker.setPAE(this);
}

void PositionAcquisitionEngine::enableLiveView() {
	if(_liveView)
		return;

    _liveView = true;
	_viewer = new LiveViewer();
}

void PositionAcquisitionEngine::disableLiveView() {
	if(!_liveView)
		return;

    _liveView = false;
	delete _viewer;
}

void PositionAcquisitionEngine::start() {
    if(_isRunning) { return; }

	// Mark the engine as running
    _isRunning = true;

    // Init OpenNI
	if(openni::OpenNI::initialize() != openni::STATUS_OK) {
		std::cout << openni::OpenNI::getExtendedError() << std::endl;
		throw "Could not itialize OpenNI";
	}
    
    // Add our event listeners to OpenNI
    openni::OpenNI::addDeviceConnectedListener(this);
    openni::OpenNI::addDeviceDisconnectedListener(this);
    
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
        onDeviceConnected(&availableDevices[i]);
    }
}

void PositionAcquisitionEngine::onDeviceConnected(const openni::DeviceInfo * deviceInfo) {
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

void PositionAcquisitionEngine::onDeviceDisconnected(const openni::DeviceInfo * deviceInfo) {
    // Get the device serial
    std::string serial = getDeviceSerial(deviceInfo);
    
    // Check the serial isn't empty
    if(serial.size() == 0) {
        return;
    }

	// Close viewer if needed
	if(_liveView) {
		_viewer->endViewer(serial);
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
	if(_devices.count(serial) == 0) {
		// Device is not here, send the action to the network
		_linker.sendAction("connectDevice", serial);
        return; // Do nothing else here
	}
    
    _devices[serial]->connect();
}

void PositionAcquisitionEngine::activateAllDevices() {
    for(auto const &device: _devices) {
        activateDevice(device.second->getSerial());
    }
}

void PositionAcquisitionEngine::activateDevice(const std::string &serial) {
    // Make sure the device specified is available
	if(_devices.count(serial) == 0) {
		// Device is not here, send the action to the network
		_linker.sendAction("activateDevice", serial);
		return; // Do nothing else here
	}
    
    _devices[serial]->setActive();
}

void PositionAcquisitionEngine::deactivateAllDevices() {
    for(auto const &device: _devices) {
        deactivateDevice(device.second->getSerial());
    }
}

void PositionAcquisitionEngine::deactivateDevice(const std::string &serial) {
    // Make sure the device specified is available
	if(_devices.count(serial) == 0) {
		// Device is not here, send the action to the network
		_linker.sendAction("deactivateDevice", serial);
		return; // Do nothing else here
	}
    
    _devices[serial]->setIdle();

	// Close viewer if needed
	if(_liveView) {
		_viewer->endViewer(serial);
	}
}

PAEStatusCollection * PositionAcquisitionEngine::getStatus() {
	PAEStatus * status = new PAEStatus();
    
    status->deviceCount = (unsigned int)_devices.size();
	memcpy(status->hostname, hostname, _POSIX_HOST_NAME_MAX);
    
    // Allocate space to store the device states (C-style baby)
    status->connectedDevices = (PAEDeviceStatus *)malloc(sizeof(PAEDeviceStatus) * status->deviceCount);
    
    // For each device currently stored, generate and store its status
    int i = 0;
    for (std::pair<std::string, PhysicalDevice *> deviceReference : _devices) {
        PhysicalDevice * device = deviceReference.second;
        status->connectedDevices[i] = device->getStatus();

		// And present the device view if needed
		if(_liveView) {
			_viewer->presentView(&(status->connectedDevices[i]), device->getColorFrame());
		}
		
		++i;
    }

    // Emit the status if needed
    if (_isEmitter) {
        _linker.send(status);
    }

	std::vector<PAEStatus *> statusList;
	statusList.push_back(status);

    // Integrate the status stored in the linker
    std::vector<PAEStatus *> foreignStatus = _linker.storedDevices();
	statusList.insert(statusList.end(), foreignStatus.begin(), foreignStatus.end());

	PAEStatusCollection * collection = new PAEStatusCollection();
	collection->statusCount = (unsigned int)statusList.size();
	collection->status = (PAEStatus **)malloc(sizeof(PAEStatus *) * collection->statusCount);

	for(int i = 0; i < collection->statusCount; ++i) {
		collection->status[i] = statusList[i];
	}
    
    return collection;
}

void PositionAcquisitionEngine::freeCollection(PAEStatusCollection * collection) {
	for(int i = 0; i < collection->statusCount; ++i) {
		freeStatus(collection->status[i]);
		collection->status[i] = nullptr;
	}

	delete collection;
	collection = nullptr;
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
