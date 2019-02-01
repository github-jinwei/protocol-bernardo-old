//
//  RigsTracker.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "UsersTracker.hpp"
#include "PhysicalDevice.hpp"

void UsersTracker::onNewFrame(nite::UserTracker &userTracker) {
    // Is the device even active ? The user tracker starts on creation
    // even though the device is not active. So make sure here we are not
    // parsing it for nothing
    if(_device->getState() != DeviceState::DEVICE_ACTIVE)
        return;
    
    // Retrieve the frame
    nite::UserTrackerFrameRef * userFrame = new nite::UserTrackerFrameRef;
    userTracker.readFrame(userFrame);
    
    // Ignore the frame if it is not valid
    if(!userFrame->isValid()) {
        return;
    }
    
    // Then, start working with the frame
    onUserFrame(userFrame);
}

User * UsersTracker::getUsers() {
    // Allocate anough space for all the users
    User * userList = (User *)malloc(sizeof(User) * _users.size());
    
    // For each user, place a reference to it in the array
    int i = 0;
    for(std::pair<nite::UserId, User *> userReference: _users) {
        userList[i] = *userReference.second;
        ++i;
    }
    
    return userList;
}

void UsersTracker::onUserFrame(nite::UserTrackerFrameRef * userFrame) {
    // Get the users on the frame
    const nite::Array<nite::UserData>& users = userFrame->getUsers();
    
    // Loop on all the provided users
    for(int i = 0;  i < users.getSize(); ++i) {
        const nite::UserData * userData = &users[i];
        
        // Handle new users
        if(userData->isNew()) {
            // This is a new user, lets register it and start its skeleton tracking
            User * user = new User();
            user->userID = userData->getId();
            user->state = UserState::USER_CALIBRATING;
            
            _users[userData->getId()] = user;
            
            _device->getRigTracker()->startSkeletonTracking(userData->getId());
            
            // We just started tracking this user, there is nothing to do with it here
            continue;
        }
        
        User * user = _users[userData->getId()];
        
        // Handle leaving users
        if(userData->isLost()) {
            // This user is not relevant anymore, stop tracking its skeleton and
            // de reference it.
            _device->getRigTracker()->stopSkeletonTracking(user->userID);
            
            _users.erase(user->userID);
            delete user;
            
            // Nothing else to do
            continue;
        }
        
        // Handle missing users
        if(!userData->isVisible()) {
            // User is not visible. Mark it as missing
            user->state = UserState::USER_MISSING;
            
            // Nothing else to do
            continue;
        }
        
        // Is this user's skeleton still calibrating ?
        if(userData->getSkeleton().getState() == nite::SkeletonState::SKELETON_CALIBRATING) {
            user->state = UserState::USER_CALIBRATING;
            
            // Nothing else to do
            continue;
        }
        
        // Is this user's skeleton errored ?
        if(userData->getSkeleton().getState() != nite::SkeletonState::SKELETON_TRACKED) {
            user->state = UserState::USER_ERRORED;
            
            // Nothing else to do
            continue;
        }
        
        
        user->state = UserState::USER_TRACKED;
        
        // If we are here, it means the user is beiing actively tracked. Let's update its structure.
        user->centerOfMass = P3FtoPosition(userData->getCenterOfMass());
        
        // Update the skeleton and all its joint coordinates
        Skeleton * userSkeleton = &user->skeleton;
        const nite::Skeleton * skeleton = &(userData->getSkeleton());
        
        userSkeleton->head = niteJointToCJoint(skeleton->getJoint(nite::JOINT_HEAD));
        userSkeleton->neck = niteJointToCJoint(skeleton->getJoint(nite::JOINT_NECK));
        userSkeleton->leftShoulder = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_SHOULDER));
        userSkeleton->rightShoulder = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_SHOULDER));
        userSkeleton->leftElbow = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_ELBOW));
        userSkeleton->rightElbow = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_ELBOW));
        userSkeleton->leftHand = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_HAND));
        userSkeleton->rightHand = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_HAND));
        userSkeleton->torso = niteJointToCJoint(skeleton->getJoint(nite::JOINT_TORSO));
        userSkeleton->leftHip = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_HIP));
        userSkeleton->rightHip = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_HIP));
        userSkeleton->leftKnee = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_KNEE));
        userSkeleton->rightKnee = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_KNEE));
        userSkeleton->leftFoot = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_FOOT));
        userSkeleton->rightFoot = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_FOOT));
    }
}


std::string UsersTracker::getStatusLabel(const nite::SkeletonState &skeletonState) {
    switch(skeletonState) {
        case nite::SKELETON_NONE:
            return "SKELETON_NONE";
        case nite::SKELETON_CALIBRATING:
            return "SKELETON_CALIBRATING";
        case nite::SKELETON_TRACKED:
            return "SKELETON_TRACKED";
        case nite::SKELETON_CALIBRATION_ERROR_NOT_IN_POSE:
            return "SKELETON_CALIBRATION_ERROR_NOT_IN_POSE";
        case nite::SKELETON_CALIBRATION_ERROR_HANDS:
            return "SKELETON_CALIBRATION_ERROR_HANDS";
        case nite::SKELETON_CALIBRATION_ERROR_HEAD:
            return "SKELETON_CALIBRATION_ERROR_HEAD";
        case nite::SKELETON_CALIBRATION_ERROR_LEGS:
            return "SKELETON_CALIBRATION_ERROR_LEGS";
        case nite::SKELETON_CALIBRATION_ERROR_TORSO:
            return "SKELETON_CALIBRATION_ERROR_TORSO";
    }
}

Joint UsersTracker::niteJointToCJoint(const nite::SkeletonJoint &joint) {
    Joint cJoint;
    
    cJoint.orientation = niteQuaternionToCQuaternion(joint.getOrientation());
    cJoint.orientationConfidence = joint.getOrientationConfidence();
    
    cJoint.position = P3FtoPosition(joint.getPosition());
    cJoint.positionConfidence = joint.getPositionConfidence();
    
    return cJoint;
}

Position UsersTracker::P3FtoPosition(const nite::Point3f &p3f) {
    Position pos;
    
    pos.x = p3f.x;
    pos.y = p3f.y;
    pos.z = p3f.z;
    
    _device->getRigTracker()->convertDepthCoordinatesToJoint(p3f.x, p3f.y, p3f.z, &pos.x2D, &pos.y2D);
    
    return pos;
}

Quaternion UsersTracker::niteQuaternionToCQuaternion(const nite::Quaternion &quaternion) {
    Quaternion cQuat;
    
    cQuat.x = quaternion.x;
    cQuat.y = quaternion.y;
    cQuat.z = quaternion.z;
    cQuat.w = quaternion.w;
    
    return cQuat;
}
