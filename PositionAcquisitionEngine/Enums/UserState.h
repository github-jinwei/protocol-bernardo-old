//
//  UserState.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef UserState_h
#define UserState_h

/** Current state of a user */
typedef enum UserState {
    /** An error occured with the user. Any tracking on it has stop and will not
     resume */
    USER_ERRORED = 10,
    
    /** The user has no skeleton */
    USER_NO_SKELETON = 11, // (yet)
    
    /** The user is beiing tracked but is still calibrating.
     A calibrating user has no skeleton. */
    USER_CALIBRATING = 12,
    
    /** The user is beiing actively tracked and has a skeleton. */
    USER_TRACKED = 13,
    
    /** The user has gone missing. It will be completely removed and its ID may
     be reassigned to a new user. */
    USER_MISSING = 14
} UserState;

#endif /* RigState_h */
