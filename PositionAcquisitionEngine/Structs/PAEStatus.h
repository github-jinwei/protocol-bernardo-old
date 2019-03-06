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

/**
 Representation of the status of the DAE
 
 Primarily used to retrieve a device status from Swift
 */
struct PAEStatus {
    /** The number of devices available */
    unsigned int deviceCount;
    
    /** The status for every available device */
    struct PAEDeviceStatus * connectedDevices;
};


#endif /* DAEStatus_h */
