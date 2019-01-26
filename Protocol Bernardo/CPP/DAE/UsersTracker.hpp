//
//  RigsTracker.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef UsersTracker_hpp
#define UsersTracker_hpp

#include <string>
#include <map>
#include <nite2/NiTE.h>

#include "Structs/User.h"

class Device;

class UsersTracker: public nite::UserTracker::NewFrameListener {
public:
    /**
     Called directly by nite every time a new UserFrame is available

     @param userTracker The current user tracker object
     */
    void onNewFrame(nite::UserTracker &userTracker);
    
    User * getUsers();
    
private:
    // Be friend with the device class so it can simply set itself as a reference here.
    // And nonetheless, the RigsTracker will always be used as a property of a device.
    // and fuck off by the way.
    friend Device;
    
    // The device this tracker is linked to
    Device * _device;
    
    std::map<nite::UserId, User *> _users;
    
    /**
     Receive a user frame provided by the user tracker.
     
     @param userFrame The latest user frame
     */
    void onUserFrame(nite::UserTrackerFrameRef * userFrame);
    
    /**
     Returns a string corresponding to the given skeleton state. Primarly used
     for debugging.

     @param skeletonState A Skeleton state
     @return The correponding label for the given state
     */
    std::string getStatusLabel(const nite::SkeletonState &skeletonState);
    
    Joint niteJointToCJoint(const nite::SkeletonJoint &joint);
    
    /**
     Convert a nite Point3F to a C struct Position
     
     @param p3f NiTE 3d Position
     @return Position struct 3D and 2D positions
     */
    Position P3FtoPosition(const nite::Point3f &p3f);
    
    Quaternion niteQuaternionToCQuaternion(const nite::Quaternion &quaternion);
    
};

#endif /* UsersTracker_hpp */
