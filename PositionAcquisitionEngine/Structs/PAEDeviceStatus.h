//
//  PAEDeviceStatus.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PAEDeviceStatus_h
#define PAEDeviceStatus_h

#include "../libraries.h"

#include "../Enums/DeviceState.h"
#include "PhysicalUser.h"

/**
 Representation of the status of a device.

 Primarily used to retrieve a device status from Swift
 */
struct PAEDeviceStatus {
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


/** Copy "constructor" (C Compliance for Swift interoperability) */
PAEDeviceStatus PAEDeviceStatus_copy(const PAEDeviceStatus &s) {
	PAEDeviceStatus c;

	strcpy(c.deviceHostname, s.deviceHostname);
	strcpy(c.deviceName, s.deviceName);
	strcpy(c.deviceSerial, s.deviceSerial);
	c.state = s.state;
	c.userCount = s.userCount;

	c.trackedUsers = (PhysicalUser *)malloc(sizeof(PhysicalUser *) * c.userCount);

	for(int i = 0; i < c.userCount; ++i) {
		c.trackedUsers[i] = s.trackedUsers[i];
	}

	return c;
}

#endif /* PAEDeviceStatus_h */
