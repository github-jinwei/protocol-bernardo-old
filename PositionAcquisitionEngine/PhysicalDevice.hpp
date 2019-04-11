//
//  Device.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Device_hpp
#define Device_hpp

#include "libraries.hpp"

#include "Structs/PAEStatus.h"
#include "UsersTracker.hpp"

/** Forward Declaration */
class PositionAcquisitionEngine;

/** Represent a real world captation devicee. Provides a abstraction on top
of OpenNI own device format.

A PhysicalDevice holds its own frame listener and control the device it represents
*/
class PhysicalDevice:
	public openni::VideoStream::NewFrameListener {
public:
    /**
     Instanciate the device

     @param device The device info object provided by OpenNI
     @param serial The serial number of the device
     */
    PhysicalDevice(const openni::DeviceInfo &device, const std::string &serial):
        _name(std::string(device.getName())),
        _serial(serial),
        _uri(std::string(device.getUri())) {}
    
    /**
     Open a connection with the device, properly initializing this class.
     You still need to call `setActive` to start getting frames
     */
    void connect();
    
    /**
     Starts streaming from the device
     */
    void setActive();
    
    /**
     "Pause" the streaming. You can still start it back by calling `setActive`
     */
    void setIdle();
    
    /**
     Used to store the last color frame received fromn the device

     @param frame The latest color frame
     */
    void storeColorFrame(openni::VideoFrameRef * frame);

	/**
	 Gives the current color frame as given by OpenNI, might be null.

	 @return The current colorFrame
	 */
	inline openni::VideoFrameRef * getColorFrame() { return _colorFrame; }
    
    /**
     Used to store the last depth frame received fromn the device
     
     @param frame The latest depth frame
     */
    void storeDepthFrame(openni::VideoFrameRef * frame);

	/**
	 Gives the current depth frame as given by OpenNI, might be null.

	 @return The current depthFrame
	 */
	inline openni::VideoFrameRef * getDepthFrame() { return _depthFrame; }
    
    /**
     Gives the current state of the device

     @return The device state
     */
    inline DeviceState getState() { return _state; }
    
    /**
     Provide a structure depicting the current state of the device

     @return The device state
     */
    PAEDeviceStatus getStatus();
    
    /**
     Gives the name of the device
     
     @return The device's name
     */
    inline std::string getName() { return _name; }
    
    /**
     Gives the URI to the device

     @return The device's URI
     */
    inline std::string getURI() { return _uri; }
    
    /**
     Gives the serial of the device
     
     @return The device's serial
     */
    inline std::string getSerial() { return _serial; }
    
    /**
     Gives the rig tracker used by this device

     @return The device's rig tracker
     */
    inline nite::UserTracker * getRigTracker() { return &_rigTracker; }

	void onNewFrame(openni::VideoStream &stream);
    
    ~PhysicalDevice();
    
private:

	// MARK: - The device

	/** The OpenNI deviceee */
	openni::Device _device;

	/** Current state of the device */
	DeviceState _state = DeviceState::DEVICE_IDLE;

    /** Name of the dvice */
    std::string _name;

    /** Serial of the devicee */
    std::string _serial;

    /** URI of the device */
    std::string _uri;

	// MARK: - Stream & Frames

    /** The device's color stream */
    openni::VideoStream _colorStream;
    
    /** The latest color frame received */
    openni::VideoFrameRef * _colorFrame = nullptr;

    /** The device depth stream */
    openni::VideoStream _depthStream;
    
    /** The latest color depth received */
    openni::VideoFrameRef * _depthFrame = nullptr;

	// MARK: - Human Pose Tracking

    /** Human pose tracker (NiTE) */
    nite::UserTracker _rigTracker;

    /** User tracker */
    UsersTracker _usersTracker;
};

#endif /* Device_hpp */
