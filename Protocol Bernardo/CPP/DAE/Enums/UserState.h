//
//  UserState.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef UserState_h
#define UserState_h

typedef enum UserState {
    USER_ERRORED,
    USER_NO_SKELETON, // (yet)
    USER_CALIBRATING,
    USER_TRACKED,
    USER_MISSING
} UserState;

#endif /* RigState_h */
