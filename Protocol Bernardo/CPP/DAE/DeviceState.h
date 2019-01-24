//
//  DeviceState.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DeviceState_h
#define DeviceState_h

typedef enum DeviceState {
    ERROR = 0,
    IDLE = 1,
    CONNECTING = 2,
    READY = 3,
    ACTIVE = 4,
    CLOSING = 6
} DeviceState;

#endif /* DeviceState_h */
