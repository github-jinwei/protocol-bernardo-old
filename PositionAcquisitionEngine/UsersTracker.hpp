//
//  RigsTracker.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef UsersTracker_hpp
#define UsersTracker_hpp

#include "libraries.hpp"

// Forward Declarations
class PhysicalDevice;

class UsersTracker: public nite::UserTracker::NewFrameListener {
public:
    /**
     Called directly by nite every time a new UserFrame is available

     @param userTracker The current user tracker object
     */
    void onNewFrame(nite::UserTracker &userTracker);
    
    PhysicalUser * getUsers();
    
private:
    /** Be friend with the device class so it can simply set itself as a reference here.
     and nonetheless, the UsersTracker will always be used as a property of a device.
     And fuck off by the way. */
    friend PhysicalDevice;
    
    // The device this tracker is linked to
    PhysicalDevice * _device;
    
    /** All the tracked users */
    std::map<nite::UserId, PhysicalUser *> _users;
    
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
    
    /**
     Transforms nite::SkeletonJoint to a Joint which conforms to C.

     @param joint The nite joint to transform
     @return The newly created joint reflecting the given nite joint
     */
    Joint niteJointToCJoint(const nite::SkeletonJoint &joint);
    
    /**
     Convert a nite Point3F to a C struct Position
     
     @param p3f NiTE 3d Position
     @return Position struct 3D and 2D positions
     */
    float3 P3FtoFloat3(const nite::Point3f &p3f);
    
    /**
     Create a Quaternion reflecting the given nite::Quaternion.

     @param quaternion The nite Quaternion
     @return The newly created Quaternion reflecting the given nite Quaternion
     */
    quatf niteQuaternionToCQuaternion(const nite::Quaternion &quaternion);
};

#endif /* UsersTracker_hpp */
