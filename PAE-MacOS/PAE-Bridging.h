//
//  PAE-Bridging.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PAE_Bridging_h
#define PAE_Bridging_h

#include "../PositionAcquisitionEngine/Structs/PAEStatus.h"

void PAEEnableLiveView();
void PAEDisableLiveView();
void PAEPrepare();
void PAEConnectToDevice(const char * c_serial);
void PAESetDeviceActive(const char * c_serial);
void PAESetDeviceIdle(const char * c_serial);

struct PAEStatus * PAEGetStatus();
void PAEFreeStatus(struct PAEStatus * status);

void PAEEndAcquisition();

void PAEShouldEmit(const int shouldEmit);
void PAEShouldReceive(const int shouldReceive);

void PAEConnectTo(const char * c_ip, const char * c_port, const int isSecure);

#endif /* PAE_Bridging_h */
