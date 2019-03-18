//
//  PAE-Interface.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PAE_Interface_h
#define PAE_Interface_h

#include "../PositionAcquisitionEngine/Structs/PAEStatus.h"

extern "C" {

    void PAEEnableLiveView();
    void PAEDisableLiveView();
    void PAEPrepare();
    void PAEConnectToDevice(const char * c_serial);
    void PAESetDeviceActive(const char * c_serial);
    void PAESetDeviceIdle(const char * c_serial);

    struct PAEStatus * PAEGetStatus();
    void PAEFreeStatus(PAEStatus * status);

    void PAEEndAcquisition();

    void PAEShouldEmit(const int shouldEmit);
    void PAEShouldReceive(const int shouldReceive);
    void PAEConnectTo(const char * c_ip, const char * c_port, const int isSecure);
}

#endif /* PAE_Interface_h */
