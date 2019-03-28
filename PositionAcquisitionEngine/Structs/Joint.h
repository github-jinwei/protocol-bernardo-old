//
//  Joint.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Joint_h
#define Joint_h

#include "../libraries.h"

/**
 Represent a joint on a skeleton.
 */
struct Joint {
    /** The current orientation of the joint */
    simd_quatf orientation;
    
    /** The confidence of NiTE when giving the orientation */
    float orientationConfidence;
    
    /** The position in 3D space of the Joint */
    simd_float3 position;
    
    /** The confidence of NiTe when giving the position */
    float positionConfidence;
};

#endif /* Joint_h */
