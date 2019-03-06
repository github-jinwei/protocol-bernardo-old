//
//  DeviceDisconnectedListener.cpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "DeviceDisconnectionListener.hpp"

#include "../PositionAcquisitionEngine.hpp"

void DeviceDisconnectionListener::onDeviceDisconnected(const openni::DeviceInfo *deviceInfo) {
    // Inform the pae of the disconnection
    pae->onDeviceDisconnected(deviceInfo);
}
