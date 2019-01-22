//
//  KinectState.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef KinectState_h
#define KinectState_h

typedef enum KinectState {
    ERROR = 0,
    IDLE = 1,
    CONNECTING = 2,
    READY = 3,
    ACTIVE = 4,
    CLOSING = 6
} KinectState;

#endif /* KinectState_h */
