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

struct Joint {
    struct Quaternion orientation;
    float orientationConfidence;
    
    struct Position position;
    float positionConfidence;
};

#endif /* Joint_h */
