//
//  UserFrameListener.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef UserFrameListener_hpp
#define UserFrameListener_hpp

#include <nite2/NiTE.h>

class Device;

class UserFrameListener: public nite::UserTracker::NewFrameListener {
public:
    void onNewFrame(nite::UserTracker &userTracker);
    
    Device * device;
};

#endif /* UserFrameListener_hpp */
