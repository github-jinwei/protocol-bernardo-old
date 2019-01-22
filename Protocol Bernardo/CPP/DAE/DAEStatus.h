//
//  DAEStatus.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DAEStatus_h
#define DAEStatus_h

#include "KinectStatus.h"

struct KinectStatus {
    char _serial[256];
    KinectState state;
};

typedef struct DAEStatus DAEStatus;

struct DAEStatus {
    unsigned int kinectCount;
    struct KinectStatus * _kinectStatus;
};


#endif /* DAEStatus_h */
