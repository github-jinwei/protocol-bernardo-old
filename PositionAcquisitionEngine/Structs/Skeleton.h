//
//  Skeleton.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Skeleton_h
#define Skeleton_h

#include "Joint.h"

/**
 Represent a user skeleton/rig. Holds all the joints composing it
 Its values are irrelevant is the user state isn't USER_TRACKED
 */
struct Skeleton {
    struct Joint head;
    struct Joint neck;
    struct Joint leftShoulder;
    struct Joint rightShoulder;
    struct Joint leftElbow;
    struct Joint rightElbow;
    struct Joint leftHand;
    struct Joint rightHand;
    struct Joint torso;
    struct Joint leftHip;
    struct Joint rightHip;
    struct Joint leftKnee;
    struct Joint rightKnee;
    struct Joint leftFoot;
    struct Joint rightFoot;
};

#endif /* Skeleton_h */
