//
//  DAE-Bridging.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DAE_Bridging_h
#define DAE_Bridging_h

#include "Structs/DAEStatus.h"

struct DAEStatus * DAEGetStatus();

void DAEPrepare();
void DAEConnectToDevice(const char * c_serial);
void DAESetDeviceActive(const char * c_serial);
void DAESetDeviceIdle(const char * c_serial);
void DAEEndAcquisition();

#endif /* DAE_Bridging_h */
