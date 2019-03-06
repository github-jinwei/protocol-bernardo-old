//
//  Joint.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Joint_h
#define Joint_h

#include "Quaternion.h"
#include "Position.h"

/**
 Represent a joint on a skeleton.
 */
struct Joint {
    /** The current orientation of the joint */
    struct Quaternion orientation;
    
    /** The confidence of NiTE when giving the orientation */
    float orientationConfidence;
    
    /** The position in 3D and 2D space of the Joint */
    struct Position position;
    
    /** The confidence of NiTe when giving the position */
    float positionConfidence;
};

#endif /* Joint_h */
