//
//  FrameListener.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef FrameListener_hpp
#define FrameListener_hpp

#include <stdio.h>
#include <ni2/OpenNI.h>

class PhysicalDevice;

class FrameListener: public openni::VideoStream::NewFrameListener {
    /**
     Called by NiTE every time a new video frame is available from a stream

     @param stream The strean who has an available frame
     */
    void onNewFrame(openni::VideoStream &stream);

public:
    /** Reference to the device */
    PhysicalDevice * device;
};

#endif /* FrameListener_hpp */
