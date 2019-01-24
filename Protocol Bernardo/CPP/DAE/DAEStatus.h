//
//  DAEStatus.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DAEStatus_h
#define DAEStatus_h

#include "DeviceState.h"

struct User {
};

struct DeviceStatus {
    char _name[256];
    char _serial[256];
    DeviceState state;
    
    unsigned int userCount;
    struct User * _users;
};

typedef struct DAEStatus DAEStatus;

struct DAEStatus {
    unsigned int deviceCount;
    struct DeviceStatus * _deviceStatus;
};


#endif /* DAEStatus_h */
