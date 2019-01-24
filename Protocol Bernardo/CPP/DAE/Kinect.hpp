//
//  Kinect.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Kinect_hpp
#define Kinect_hpp

#include <iostream>
#include <string>

#include <ni2/OpenNI.h>

#include "DAEStatus.h"
#include "FrameListener.hpp"

class Kinect {
public:
    /**
     Instanciate the device

     @param device The device info object provided by OpenNI
     @param serial The serial number of the device
     */
    Kinect(const openni::DeviceInfo &device, const std::string &serial):
        _name(std::string(device.getName())),
        _serial(serial),
        _uri(std::string(device.getUri())) {}
    
    /**
     Open a connection with the kinect, properly initializing this class.
     You still need to call `setActive` to start getting frames
     */
    void connect();
    
    /**
     Starts streaming from the kinect
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
     Provide a structure depicting the current state of the kinect

     @return The kinect state
     */
    KinectStatus getState();
    
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
    
    ~Kinect();
    
private:
    std::string _name;
    std::string _serial;
    std::string _uri;
    
    openni::Device _device;
    
    openni::VideoStream _colorStream;
    openni::VideoFrameRef * _colorFrame = nullptr;
    
    openni::VideoStream _depthStream;
    openni::VideoFrameRef * _depthFrame = nullptr;
    
    FrameListener _colorStreamListener;
    FrameListener _depthStreamListener;
    
    KinectState _state = KinectState::IDLE;
};

#endif /* Kinect_hpp */
