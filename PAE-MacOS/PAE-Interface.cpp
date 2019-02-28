//
//  PAE-Bridging.cpp
//  PAE-MacOS
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include <iostream>

#include "PAE-Interface.hpp"

#include "PAEMacOSApp.hpp"
#include "../PositionAcquisitionEngine/PositionAcquisitionEngine.hpp"

void PAEEnableLiveView() {
    PAEMacOSApp->pae->enableLiveView();
}

void PAEDisableLiveView() {
    PAEMacOSApp->pae->disableLiveView();
}

void PAEPrepare() {
    PAEMacOSApp->pae->start();
}

void PAEConnectToDevice(const char * c_serial) {
    std::string serial = c_serial;
    PAEMacOSApp->pae->connectToDevice(serial);
}

void PAESetDeviceActive(const char * c_serial) {
    std::string serial = c_serial;
    PAEMacOSApp->pae->setDeviceActive(serial);
}

void PAESetDeviceIdle(const char * c_serial) {
    std::string serial = c_serial;
    PAEMacOSApp->pae->setDeviceIdle(serial);
}

void PAEEndAcquisition() {
    PAEMacOSApp->pae->stop();
}

PAEStatus * PAEGetStatus() {
    return PAEMacOSApp->pae->getStatus();
}

void PAEFreeStatus(PAEStatus * status) {
    PAEMacOSApp->pae->freeStatus(status);
}
