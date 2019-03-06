//
//  Device.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Device_hpp
#define Device_hpp

#include <iostream>
#include <string>

#include <ni2/OpenNI.h>
#include <nite2/NiTE.h>

#include "PAEStatus.h"
#include "Listeners/FrameListener.hpp"
#include "UsersTracker.hpp"

/** Forward Declaration */
class PositionAcquisitionEngine;

/** Represent a real world captation devicee. Provides a abstraction on top
of OpenNI own device format.

A PhysicalDevice holds its own frame listener and control the device it represents
*/
class PhysicalDevice {
public:
    /**
     Instanciate the device

     @param device The device info object provided by OpenNI
     @param serial The serial number of the device
     */
    PhysicalDevice(const openni::DeviceInfo &device, const std::string &serial, PositionAcquisitionEngine * pae):
        _name(std::string(device.getName())),
        _serial(serial),
        _uri(std::string(device.getUri())),
        _pae(pae) {}
    
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
     Used to store the last depth frame received fromn the device
     
     @param frame The latest depth frame
     */
    void storeDepthFrame(openni::VideoFrameRef * frame);
    
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
    
    ~PhysicalDevice();
    
private:
    /** Name of the dvice */
    std::string _name;

    /** Serial of the devicee */
    std::string _serial;

    /** URI of the device */
    std::string _uri;

    /** Reference to the PAE */
    PositionAcquisitionEngine * _pae;

    /** The OpenNI deviceee */
    openni::Device _device;

    /** The device's color stream */
    openni::VideoStream _colorStream;
    
    /** The latest color frame received */
    openni::VideoFrameRef * _colorFrame = nullptr;

    /** The device depth stream */
    openni::VideoStream _depthStream;
    
    /** The latest color depth received */
    openni::VideoFrameRef * _depthFrame = nullptr;

    /** The color stream listener */
    FrameListener _colorStreamListener;

    /** The depth stream listener */
    FrameListener _depthStreamListener;

    /** Current state of the device */
    DeviceState _state = DeviceState::DEVICE_IDLE;

    /** Human pose tracker (NiTE) */
    nite::UserTracker _rigTracker;
    
    /** The latest user frame received */
    nite::UserTrackerFrameRef * _userFrame;

    /** User tracker */
    UsersTracker _usersTracker;
};

#endif /* Device_hpp */
