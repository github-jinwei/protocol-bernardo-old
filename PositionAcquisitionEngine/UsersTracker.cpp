//
//  RigsTracker.cpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PhysicalDevice.hpp"

#include "UsersTracker.hpp"
#include "Structs/PhysicalUser.h"

static const float kPi = 3.141592653589793238462643383280f;
static const float kPiDiv2 = 1.570796326794896619231321691640f;

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
    
    delete userFrame;
}

PhysicalUser * UsersTracker::getUsers() {
    // Allocate anough space for all the users
    PhysicalUser * userList = (PhysicalUser *)malloc(sizeof(PhysicalUser) * _users.size());
    
    // For each user, place a reference to it in the array
    int i = 0;
    for(std::pair<nite::UserId, PhysicalUser *> userReference: _users) {
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
            PhysicalUser * user = new PhysicalUser();
            user->userID = userData->getId();
            user->frame = 0;
            user->state = UserState::USER_CALIBRATING;
            
            _users[userData->getId()] = user;
            
            _device->getRigTracker()->startSkeletonTracking(userData->getId());
            
            // We just started tracking this user, there is nothing to do with it here
            continue;
        }
        
        PhysicalUser * user = _users[userData->getId()];
        
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

        // User is ok, update its skeleton
        user->state = UserState::USER_TRACKED;
        ++user->frame;
        
        // If we are here, it means the user is being actively tracked. Let's update its structure.
        user->centerOfMass = P3FtoFloat3(userData->getCenterOfMass());
        
        // Update the skeleton and all its joint coordinates
        Skeleton * userSkeleton = &user->skeleton;
        const nite::Skeleton * skeleton = &(userData->getSkeleton());
        
        userSkeleton->head          = niteJointToCJoint(skeleton->getJoint(nite::JOINT_HEAD));
        userSkeleton->neck          = niteJointToCJoint(skeleton->getJoint(nite::JOINT_NECK));
        userSkeleton->leftShoulder  = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_SHOULDER));
        userSkeleton->rightShoulder = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_SHOULDER));
        userSkeleton->leftElbow     = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_ELBOW));
        userSkeleton->rightElbow    = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_ELBOW));
        userSkeleton->leftHand      = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_HAND));
        userSkeleton->rightHand     = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_HAND));
        userSkeleton->torso         = niteJointToCJoint(skeleton->getJoint(nite::JOINT_TORSO));
        userSkeleton->leftHip       = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_HIP));
        userSkeleton->rightHip      = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_HIP));
        userSkeleton->leftKnee      = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_KNEE));
        userSkeleton->rightKnee     = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_KNEE));
        userSkeleton->leftFoot      = niteJointToCJoint(skeleton->getJoint(nite::JOINT_LEFT_FOOT));
        userSkeleton->rightFoot     = niteJointToCJoint(skeleton->getJoint(nite::JOINT_RIGHT_FOOT));

//        recalculateOrientations(userSkeleton);
    }
}

//void UsersTracker::recalculateOrientations(::Skeleton * skeleton) {
//    // If the arms are not standard 'T' pose, you may set an offset angle.
//    const float arm_angle = 0.0f;
//    const float arm_angle_scaler = (arm_angle + 90.0f) / 90.0f;
//
//    const float MAX_STABLE_DOT = 0.925f;
//    float dot;
//    simd_float3 p1, p2;
//    simd_float3 v1, v2;
//    simd_float3 vx, vy, vz;
//    simd_float3 v_body_x;
//    simd_float3x3 m, mr;
//    simd_quatf q;
//
//    // JOINT_TORSO
//    p1 = skeleton->leftHip.position;
//    p2 = skeleton->rightHip.position;
//    vx = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->torso.position;
//    p2 = skeleton->neck.position;
//    vy = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    q = simd_quaternion(m);
//    skeleton->torso.orientation = q;
//
//    // save body's axis x for later use
//    v_body_x = vx;
//
//    // JOINT_NECK
//    p1 = skeleton->leftShoulder.position;
//    p2 = skeleton->rightShoulder.position;
//    vx = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->neck.position;
//    p2 = skeleton->head.position;
//    vy = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    q = simd_quaternion(m);
//    skeleton->neck.orientation = q;
//    // JOINT_HEAD
//    skeleton->head.orientation = skeleton->neck.orientation;
//
//    // JOINT_LEFT_SHOULDER
//    p1 = skeleton->leftShoulder.position;
//    p2 = skeleton->leftElbow.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->leftElbow.position;
//    p2 = skeleton->leftHand.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
////    if (fabsf(dot) > MAX_STABLE_DOT) {
////        vx = last_stable_vx[JOINT_LEFT_SHOULDER];
////    } else {
//        vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
////        last_stable_vx[JOINT_LEFT_SHOULDER] = vx;
////    }
//    vy = v1;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(kPiDiv2 * arm_angle_scaler));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->leftShoulder.orientation = q;
//
//    // JOINT_LEFT_ELBOW
//    p1 = skeleton->leftShoulder.position;
//    p2 = skeleton->leftElbow.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->leftElbow.position;
//    p2 = skeleton->leftHand.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
////    if (fabsf(dot) > MAX_STABLE_DOT) {
////        vx = last_stable_vx[JOINT_LEFT_ELBOW];
////    } else {
//        vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
////        last_stable_vx[JOINT_LEFT_ELBOW] = vx;
////    }
//    vy = v2;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(kPiDiv2 * arm_angle_scaler));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->leftElbow.orientation = q;
//
//    // JOINT_LEFT_HAND
//    skeleton->leftHand.orientation = skeleton->leftElbow.orientation;
//
//    // JOINT_RIGHT_SHOULDER
//    p1 = skeleton->rightShoulder.position;
//    p2 = skeleton->rightElbow.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->rightElbow.position;
//    p2 = skeleton->rightHand.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
////    if (fabsf(dot) > MAX_STABLE_DOT) {
////        vx = last_stable_vx[JOINT_RIGHT_SHOULDER];
////    } else {
//        vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
////        last_stable_vx[JOINT_RIGHT_SHOULDER] = vx;
////    }
//    vy = v1;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(-kPiDiv2 * arm_angle_scaler));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->rightShoulder.orientation = q;
//
//    // JOINT_RIGHT_ELBOW
//    p1 = skeleton->rightShoulder.position;
//    p2 = skeleton->rightElbow.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->rightElbow.position;
//    p2 = skeleton->rightHand.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
////    if (fabsf(dot) > MAX_STABLE_DOT) {
////        vx = last_stable_vx[JOINT_RIGHT_ELBOW];
////    } else {
//        vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
////        last_stable_vx[JOINT_RIGHT_ELBOW] = vx;
////    }
//    vy = v2;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(-kPiDiv2 * arm_angle_scaler));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->rightElbow.orientation = q;
//
//    // JOINT_RIGHT_HAND
//    skeleton->rightHand.orientation = skeleton->rightElbow.orientation;
//
//    // JOINT_LEFT_HIP
//    p1 = skeleton->leftHip.position;
//    p2 = skeleton->leftKnee.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->leftKnee.position;
//    p2 = skeleton->leftFoot.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
//    vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
//    // constrain to body's axis x
//    vx = simd_normalize(v_body_x) * dot + simd_normalize(vx) * (1 - dot);
//    // reverse the direction because knees can only bend to back
//    vx = -vx;
//    vy = v1;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(kPi));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->leftHip.orientation = q;
//
//    // JOINT_LEFT_KNEE
//    p1 = skeleton->leftHip.position;
//    p2 = skeleton->leftKnee.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->leftKnee.position;
//    p2 = skeleton->leftFoot.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
//    vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
//    // constrain to body's axis x
//    vx = simd_normalize(v_body_x) * dot + simd_normalize(vx) * (1 - dot);
//    // reverse the direction because knees can only bend to back
//    vx = -vx;
//    vy = v2;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(kPi));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->leftKnee.orientation = q;
//
//    // JOINT_LEFT_FOOT
//    skeleton->leftFoot.orientation = skeleton->leftKnee.orientation;
//
//    // JOINT_RIGHT_HIP
//    p1 = skeleton->rightHip.position;
//    p2 = skeleton->rightKnee.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->rightKnee.position;
//    p2 = skeleton->rightFoot.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
//    vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
//    // constrain to body's axis x
//    vx = simd_normalize(v_body_x) * dot + simd_normalize(vx) * (1 - dot);
//    // reverse the direction because knees can only bend to back
//    vx = -vx;
//    vy = v1;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(kPi));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->rightHip.orientation = q;
//
//    // JOINT_RIGHT_KNEE
//    p1 = skeleton->rightHip.position;
//    p2 = skeleton->rightKnee.position;
//    v1 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    p1 = skeleton->rightKnee.position;
//    p2 = skeleton->rightFoot.position;
//    v2 = simd_make_float3(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
//    dot = simd_dot(simd_normalize(v1), simd_normalize(v2));
//    vx = simd_cross(simd_normalize(v1), simd_normalize(v2));
//    // constrain to body's axis x
//    vx = simd_normalize(v_body_x) * dot + simd_normalize(vx) * (1 - dot);
//    // reverse the direction because knees can only bend to back
//    vx = -vx;
//    vy = v2;
//    vz = simd_make_float3(0, 0, 0);
//    m = simd_matrix_from_rows(vx, vy, vz);
//    // inverse bind pose
//    mr = simd_inverse(rotationMatrix(kPi));
//    m = simd_mul(mr, m);
//    q = simd_quaternion(m);
//    skeleton->rightKnee.orientation = q;
//
//    // JOINT_RIGHT_FOOT
//    skeleton->rightFoot.orientation = skeleton->rightKnee.orientation;
//}
//
//simd_float3x3 UsersTracker::rotationMatrix(const float &rad) {
//    float c = cosf(rad);
//    float s = sinf(rad);
//    simd_float3x3 r = simd_matrix_from_rows(simd_make_float3(c, s, 0),
//                                            simd_make_float3(-s, c, 0),
//                                            simd_make_float3(0, 0, 1));
//    return r;
//}

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

    // Joint coordinates are given in real world coordinates
    cJoint.position = P3FtoFloat3(joint.getPosition());
    cJoint.positionConfidence = joint.getPositionConfidence();
    
    return cJoint;
}

simd_float3 UsersTracker::P3FtoFloat3(const nite::Point3f &p3f) {
    return simd_make_float3(p3f.x, p3f.y, p3f.z);
}

simd_quatf UsersTracker::niteQuaternionToCQuaternion(const nite::Quaternion &quaternion) {
    return simd_quaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
}
