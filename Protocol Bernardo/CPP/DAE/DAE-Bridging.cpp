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
    App->dae->main();
}

void DAEParseForKinects() {
    App->dae->parseForKinects();
}

void DAEConnectToKinect(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->connectToKinect(serial);
}

void DAESetKinectActive(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->setKinectActive(serial);
}

void DAESetKinectIdle(const char * c_serial) {
    std::string serial = c_serial;
    App->dae->setKinectIdle(serial);
}

void DAEEndAcquisition() {
    delete App->dae;
    App->dae = nullptr;
}

DAEStatus * DAEGetStatus() {
    return App->dae->getStatus();
}
