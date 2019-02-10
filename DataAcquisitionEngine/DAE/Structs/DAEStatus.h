//
//  DAEStatus.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DAEStatus_h
#define DAEStatus_h

#include "../Enums/DeviceState.h"
#include "PhysicalUser.h"

/**
 Representation of the status of a device.
 
 Primarily used to retrieve a device status from Swift
 */
struct DAEDeviceStatus {
    /** Name of the device (C String) */
    char _name[256];
    
    /** Serial of the device (C String) */
    char _serial[256];
    
    /** The current state of the device */
    DeviceState state;
    
    /** The number of users this device is currently tracking */
    unsigned int userCount;
    
    /** All the users tracked by the device */
    struct PhysicalUser * _users;
};

/**
 Representation of the status of the DAE
 
 Primarily used to retrieve a device status from Swift
 */
struct DAEStatus {
    /** The number of devices available */
    unsigned int deviceCount;
    
    /** The status for every available device */
    struct DAEDeviceStatus * _deviceStatus;
};


#endif /* DAEStatus_h */
