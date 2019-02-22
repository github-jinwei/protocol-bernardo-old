//
//  PhysicalUser.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef User_h
#define User_h

#include "../Enums/UserState.h"
#include "Skeleton.h"

/**
 Represent a user tracked by a device
 */
struct PhysicalUser {
    /** The userID for the user, given by NiTE */
    short int /* nite::UserId */ userID;
    
    /** The state of this user */
    UserState state;
    
    /** The skeleton of the user. Irrevelant if the user state isn't USER_TRACKED */
    struct Skeleton skeleton;
    
    /** The center of mass of the user. Irrevelant is the user state isn't USER_TRACKED  */
    struct Position centerOfMass;
};

#endif /* User_h */
