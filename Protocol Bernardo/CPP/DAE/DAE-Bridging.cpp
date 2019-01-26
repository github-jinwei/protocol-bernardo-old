//
//  DAE-Bridging.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include <iostream>

#include "DAE-Bridging.hpp"
#include "../App.hpp"
#include "DataAcquisitionEngine.hpp"

void DAEPrepare() {
    App->dae = DataAcquisitionEngine::getInstance();
    App->dae->start();
}

void DAEParseForDevices() {
    App->dae->parseForDevices();
}

void DAEConnectToDevice(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->connectToDevice(serial);
}

void DAESetDeviceActive(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->setDeviceActive(serial);
}

void DAESetDeviceIdle(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->setDeviceIdle(serial);
}

void DAEEndAcquisition() {
    App->dae->stop();
}

DAEStatus * DAEGetStatus() {
    return App->dae->getStatus();
}
