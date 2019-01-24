//
//  FrameListener.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "FrameListener.hpp"
#include "Device.hpp"

void FrameListener::onNewFrame(openni::VideoStream &stream) {
    openni::VideoFrameRef * frame = new openni::VideoFrameRef();
    stream.readFrame(frame);
    
    openni::SensorType sensorType = stream.getSensorInfo().getSensorType();
    
    switch (sensorType) {
        case openni::SENSOR_COLOR:
            std::cout << "Received COLOR frame" << std::endl;
            device->storeColorFrame(frame);
            break;
        case openni::SENSOR_DEPTH:
            std::cout << "Received DEPTH frame" << std::endl;
            device->storeDepthFrame(frame);
            break;
        default:
            return;
    }
}
