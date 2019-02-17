//
//  DeviceState.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DeviceState_h
#define DeviceState_h

/**
 Current state of a device
 */
typedef enum DeviceState {
    /** The state of the device is unknown. Used for not connected devices */
    DEVICE_UNKNOWN,

    /** An errored occured with the device. This make it unusable. */
    DEVICE_ERROR,
    
    /** The device has been detected but is not currently connected. No data
     are beiing exchanged with it. */
    DEVICE_IDLE,
    
    /** The driver is opening a connection with the device */
    DEVICE_CONNECTING,
    
    /** The device is connected and ready to collect data. At this point,
     no video streams are opened */
    DEVICE_READY,
    
    /** The device is actively transfering data/video streams. */
    DEVICE_ACTIVE,
    
    /** The connection to the device is beiing closed */
    DEVICE_CLOSING
} DeviceState;

#endif /* DeviceState_h */
