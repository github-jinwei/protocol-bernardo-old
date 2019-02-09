//
//  DeviceConnectionListener.hpp
//  DataAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DeviceConnectionListener_hpp
#define DeviceConnectionListener_hpp

#include <iostream>
#include <ni2/OpenNI.h>

class DataAcquisitionEngine;

class DeviceConnectionListener: public openni::OpenNI::DeviceConnectedListener {
public:
    void onDeviceConnected(const openni::DeviceInfo * deviceInfo);
    
    DataAcquisitionEngine * dae;
};

#endif /* DeviceConnectionListener_hpp */
