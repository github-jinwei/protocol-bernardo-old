//
//  Position.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Position_h
#define Position_h

/**
 Represent a 3D position in the field of view of the device and the 2D position
 of the point on the frame
 */
struct Position {
    float x;
    float y;
    float z;
    
    float x2D;
    float y2D;
};

#endif /* Position_h */
