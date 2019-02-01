//
//  FrameListener.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "FrameListener.hpp"
#include "PhysicalDevice.hpp"

void FrameListener::onNewFrame(openni::VideoStream &stream) {
    openni::VideoFrameRef * frame = new openni::VideoFrameRef();
    stream.readFrame(frame);
    
    openni::SensorType sensorType = stream.getSensorInfo().getSensorType();
    
    switch (sensorType) {
        case openni::SENSOR_COLOR:
            device->storeColorFrame(frame);
            break;
        case openni::SENSOR_DEPTH:
            device->storeDepthFrame(frame);
            break;
        default:
            return;
    }
}
