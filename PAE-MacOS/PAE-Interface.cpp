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
#include "../PositionAcquisitionEngine/PAELinker.hpp"

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

void PAEShouldEmit(const int shouldEmit) {
    PAEMacOSApp->pae->shouldEmit(shouldEmit);
}

void PAEShouldReceive(const int shouldReceive) {
    PAEMacOSApp->pae->linker()->shouldReceive(shouldReceive);
}

void PAEConnectTo(const char * c_ip, const char * c_port, const int isSecure) {
    std::string ip = c_ip;
    std::string port = c_port;

    PAEMacOSApp->pae->linker()->connect(ip, port, isSecure);
}
