//
//  SkeletonJoint.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

/// All the joints composing a skeleton as tracked by NiTE2
enum SkeletonJoint: String, CaseIterable {
    /// Head joint
    case head

    /// Neck joint
    case neck

    /// Left shoulder joint
    case leftShoulder

    /// right shoulder joint
    case rightShoulder

    /// left Elbow joint
    case leftElbow

    /// right elbow joint
    case rightElbow

    /// left hand joint
    case leftHand

    /// Right hand joint
    case rightHand

    /// Torse joint
    case torso

    /// Left hip joint
    case leftHip

    /// Right hip joint
    case rightHip

    /// Left knee joint
    case leftKnee

    /// Right knee joint
    case rightKnee

    /// Left foot joint
    case leftFoot

    /// Right foot joints
    case rightFoot
}
