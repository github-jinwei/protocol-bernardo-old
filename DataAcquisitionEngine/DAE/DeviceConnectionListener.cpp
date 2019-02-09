//
//  DeviceConnectionListener.cpp
//  DataAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "DeviceConnectionListener.hpp"

#include "DataAcquisitionEngine.hpp"

void DeviceConnectionListener::onDeviceConnected(const openni::DeviceInfo *deviceInfo) {
    std::cout << "Device Connected" << std::endl;
    // Inform the dae of the connection
    dae->onNewDevice(deviceInfo);
}
