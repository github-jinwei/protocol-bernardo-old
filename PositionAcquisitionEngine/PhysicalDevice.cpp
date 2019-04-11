//
//  Device.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PhysicalDevice.hpp"
#include "PositionAcquisitionEngine.hpp"

void PhysicalDevice::connect() {
    if(_state != DEVICE_IDLE) { return; }

    _state = DeviceState::DEVICE_CONNECTING;
    
    // Open the device
    if (_device.open(_uri.c_str()) != openni::STATUS_OK)
    {
        printf("Coudle not open the device:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    _device.setDepthColorSyncEnabled(true);
    
    // ////////////////////////
    // Create the color stream
    if(_colorStream.create(_device, openni::SENSOR_COLOR) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    // Set its properties
    openni::VideoMode colorVideoMode;
    colorVideoMode.setResolution(640, 480);
    colorVideoMode.setFps(30);
    colorVideoMode.setPixelFormat(openni::PIXEL_FORMAT_RGB888);
    _colorStream.setVideoMode(colorVideoMode);
    _colorStream.addNewFrameListener(this);
    _colorStream.setMirroringEnabled(true);
    
    
    // ////////////////////////
    // Create the depth stream
    
    if(_depthStream.create(_device, openni::SENSOR_DEPTH) != openni::STATUS_OK) {
        printf("Coudle not create the color stream:\n%s\n", openni::OpenNI::getExtendedError());
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    // Set its properties
    openni::VideoMode depthVideoMode;
    depthVideoMode.setResolution(640, 480);
    depthVideoMode.setFps(30);
    depthVideoMode.setPixelFormat(openni::PIXEL_FORMAT_DEPTH_1_MM);
    _depthStream.setVideoMode(depthVideoMode);
    _depthStream.addNewFrameListener(this);
    
    
    // Set the registration mode
    _device.setImageRegistrationMode(openni::IMAGE_REGISTRATION_DEPTH_TO_COLOR);
    
    // Init the user tracker
    _rigTracker.create(&_device);
    _rigTracker.setSkeletonSmoothingFactor(.25f);
    _usersTracker._device = this;
    _rigTracker.addNewFrameListener(&_usersTracker);
    
    // Mark the device as ready
    _state = DeviceState::DEVICE_READY;
}

void PhysicalDevice::setActive() {
    // Do nothing if the device is not ready to stream
    if(_state != DeviceState::DEVICE_READY)
        return;

    // Start the streams
    if(_colorStream.start() != openni::STATUS_OK) {
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    if(_depthStream.start() != openni::STATUS_OK) {
        _state = DeviceState::DEVICE_ERROR;
        return;
    }
    
    _state = DeviceState::DEVICE_ACTIVE;
}

void PhysicalDevice::setIdle() {
    if(_state != DeviceState::DEVICE_ACTIVE) {
		return;
	}

	// Close the streams
	_colorStream.stop();
	_depthStream.stop();

	// Update the device status;
	_state = DeviceState::DEVICE_READY;
}

void PhysicalDevice::storeColorFrame(openni::VideoFrameRef *frame) {
    if(_colorFrame != nullptr)
        delete _colorFrame;
    
    _colorFrame = frame;
}

void PhysicalDevice::storeDepthFrame(openni::VideoFrameRef *frame) {
    if(_depthFrame != nullptr)
        delete _depthFrame;
    
    _depthFrame = frame;
}

PAEDeviceStatus PhysicalDevice::getStatus() {
    PAEDeviceStatus status;
    strcpy(status.deviceName, _name.c_str());
    strcpy(status.deviceSerial, _serial.c_str());
    status.state = _state;
    
    status.userCount = (unsigned int) _usersTracker._users.size();
    status.trackedUsers = _usersTracker.getUsers();

    return status;
}

void PhysicalDevice::onNewFrame(openni::VideoStream &stream) {
	openni::VideoFrameRef * frame = new openni::VideoFrameRef();
	stream.readFrame(frame);

	openni::SensorType sensorType = stream.getSensorInfo().getSensorType();

	switch (sensorType) {
		case openni::SENSOR_COLOR:
			storeColorFrame(frame);
			break;
		case openni::SENSOR_DEPTH:
			storeDepthFrame(frame);
			break;
		default:
			delete frame;
			return;
	}
}

PhysicalDevice::~PhysicalDevice() {
    // Start by making sure the device is idle
    setIdle();
    
    // There is nothing to free if the device wasn't connected
    if(_state == DeviceState::DEVICE_IDLE) {
        return;
    }
    
    // Mark the device as closing
    _state = DeviceState::DEVICE_CLOSING;
    
    // Properly free resources
    _colorStream.destroy();
    _depthStream.destroy();
    
    delete _colorFrame;
    delete _depthFrame;
    
    _device.close();
}
