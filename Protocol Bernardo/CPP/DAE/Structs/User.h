//
//  User.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef User_h
#define User_h

#include "../Enums/UserState.h"
#include "Skeleton.h"

struct User {
    short int /* nite::UserId */ userID;
    UserState state;
    
    struct Skeleton skeleton;
    
    struct Position centerOfMass;
};

#endif /* User_h */
