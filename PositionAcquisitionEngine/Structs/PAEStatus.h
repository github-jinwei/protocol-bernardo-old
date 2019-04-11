//
//  PAEStatus.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DAEStatus_h
#define DAEStatus_h

#include "PAEDeviceStatus.h"

#include <limits.h>
#include <string.h>

/**
 Representation of the status of the DAE
 
 Primarily used to retrieve a device status from Swift
 */
typedef struct PAEStatus {
	/** Name of the machine (C String) */
	char hostname[_POSIX_HOST_NAME_MAX + 1];

    /** The number of devices available */
    unsigned int deviceCount;
    
    /** The status for every available device */
    struct PAEDeviceStatus * connectedDevices;
} PAEStatus;

PAEStatus * PAEStatus_copy(PAEStatus * s);

struct PAEStatusCollection {
	unsigned int statusCount;

	struct PAEStatus ** status;
};


#endif /* DAEStatus_h */
