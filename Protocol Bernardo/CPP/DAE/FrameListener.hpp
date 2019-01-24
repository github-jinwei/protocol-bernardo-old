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

class Device;

class FrameListener: public openni::VideoStream::NewFrameListener {
    void onNewFrame(openni::VideoStream &stream);

public:
    Device * device;
};

#endif /* FrameListener_hpp */
