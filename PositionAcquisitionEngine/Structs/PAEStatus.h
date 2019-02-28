//
//  PAEStatus.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DAEStatus_h
#define DAEStatus_h

#include <unistd.h>
#include <limits.h>

#include "../Enums/DeviceState.h"
#include "PhysicalUser.h"

/**
 Representation of the status of a device.
 
 Primarily used to retrieve a device status from Swift
 */
struct DAEDeviceStatus {
    /** Name of the machine (C String) */
    char deviceHostname[_POSIX_HOST_NAME_MAX + 1];

    /** Name of the device (C String) */
    char deviceName[256];
    
    /** Serial of the device (C String) */
    char deviceSerial[256];
    
    /** The current state of the device */
    DeviceState state;
    
    /** The number of users this device is currently tracking */
    unsigned int userCount;
    
    /** All the users tracked by the device */
    struct PhysicalUser * trackedUsers;
};

/**
 Representation of the status of the DAE
 
 Primarily used to retrieve a device status from Swift
 */
struct PAEStatus {
    /** The number of devices available */
    unsigned int deviceCount;
    
    /** The status for every available device */
    struct DAEDeviceStatus * connectedDevices;
};


#endif /* DAEStatus_h */
