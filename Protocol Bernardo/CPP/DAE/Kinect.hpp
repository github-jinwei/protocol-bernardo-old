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

#include <libfreenect2/libfreenect2.hpp>
#include <libfreenect2/frame_listener_impl.h>
#include <libfreenect2/registration.h>
#include <libfreenect2/packet_pipeline.h>
#include <libfreenect2/logger.h>

#include "DAEStatus.h"

class Kinect {
public:
    Kinect(const std::string &serial): _serial(serial) {}
    
    /**
     Open a connection with the kinect, properly initializing this class.
     You still need to call `setActive` to start getting frames

     @param freenect2 The freenect2 object this class will use to connect
     */
    void connect(libfreenect2::Freenect2 * freenect2);
    
    /**
     Starts streaming from the kinect
     */
    void setActive();
    
    /**
     "Pause" the streaming. You can still start it back by calling `setActive`
     */
    void setIdle();
    
    /**
     Get the frames from the Kinect.
     If no frames are available, or if the kinect isn't active, returns nullptr

     @discussion The frames needs to be free-ed. Use the `freeFrames` method of
     this class
     
     @return The frames collected from the kinect
     */
    libfreenect2::FrameMap * getFrames();
    
    /**
     Properly free the given frames.

     @param frames The frames to free
     */
    inline void freeFrames(libfreenect2::FrameMap &frames) {
        _listener->release(frames);
    }
    
    /**
     Provide a structure depicting the current state of the kinect

     @return The kinect state
     */
    KinectStatus getState();
    
    inline std::string getSerial() { return _serial; }
    
    ~Kinect();
    
private:
    std::string _serial;
    libfreenect2::PacketPipeline * _pipeline;
    libfreenect2::Freenect2Device * _device;
    libfreenect2::SyncMultiFrameListener * _listener;
    
    KinectState _state = KinectState::IDLE;
};

#endif /* Kinect_hpp */
