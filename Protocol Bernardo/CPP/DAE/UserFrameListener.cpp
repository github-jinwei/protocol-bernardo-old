//
//  UserFrameListener.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "UserFrameListener.hpp"
#include "Device.hpp"

void UserFrameListener::onNewFrame(nite::UserTracker &userTracker) {
    nite::UserTrackerFrameRef * userFrame = new nite::UserTrackerFrameRef;
    userTracker.readFrame(userFrame);
    
    std::cout << "Received User frame" << std::endl;
    
    device->onUserFrame(userFrame);
}

