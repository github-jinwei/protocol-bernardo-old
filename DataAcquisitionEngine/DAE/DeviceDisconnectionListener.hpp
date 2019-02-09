//
//  DeviceDisconnectionListener.hpp
//  DataAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DeviceDisconnectedListener_hpp
#define DeviceDisconnectedListener_hpp

#include <iostream>
#include <ni2/OpenNI.h>

class DataAcquisitionEngine;

class DeviceDisconnectionListener: public openni::OpenNI::DeviceDisconnectedListener {
public:
    void onDeviceDisconnected(const openni::DeviceInfo * deviceInfo);

    DataAcquisitionEngine * dae;
};

#endif /* DeviceDisconnectedListener_hpp */
