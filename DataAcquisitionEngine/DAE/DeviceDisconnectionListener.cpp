//
//  DeviceDisconnectedListener.cpp
//  DataAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "DeviceDisconnectionListener.hpp"

#include "DataAcquisitionEngine.hpp"

void DeviceDisconnectionListener::onDeviceDisconnected(const openni::DeviceInfo *deviceInfo) {
    std::cout << "Device disconnected" << std::endl;
    // Inform the dae of the connection
    dae->onDeviceDisconnected(deviceInfo);
}
