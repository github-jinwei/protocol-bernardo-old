//
//  SkeletonJoint.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

/// All the joints composing a skeleton as tracked by NiTE2
enum SkeletonJoint: String, CaseIterable {
    /// Torse joint
    case torso

    /// Neck joint
    case neck

    /// Head joint
    case head

    /// Left shoulder joint
    case leftShoulder

    /// left Elbow joint
    case leftElbow

    /// left hand joint
    case leftHand

    /// right shoulder joint
    case rightShoulder

    /// right elbow joint
    case rightElbow

    /// Right hand joint
    case rightHand

    /// Left hip joint
    case leftHip

    /// Left knee joint
    case leftKnee

    /// Left foot joint
    case leftFoot

    /// Right hip joint
    case rightHip

    /// Right knee joint
    case rightKnee

    /// Right foot joints
    case rightFoot

    /// The parent skeleton Joint for the current joint.
    /// The torso joint doesn't have a parent, parent will return torso for this one.
    var parent: SkeletonJoint {
        switch self {
        case .torso: return .torso
        case .neck: return .torso
        case .head: return .neck
        case .leftShoulder: return .neck
        case .leftElbow: return .leftShoulder
        case .leftHand: return .leftElbow
        case .rightShoulder: return .neck
        case .rightElbow: return .rightShoulder
        case .rightHand: return .rightElbow
        case .leftHip: return .torso
        case .leftKnee: return .leftHip
        case .leftFoot: return .leftKnee
        case .rightHip: return .torso
        case .rightKnee: return .rightHip
        case .rightFoot: return .rightKnee
        }
    }
}
