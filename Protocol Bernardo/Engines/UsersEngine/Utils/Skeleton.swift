//
//  Skeleton.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Skeleton, as tracked by NiTE2, is composed of 15 joints, each defined by their position
/// in the 2D and 3d position in the space of the acquisition device, and a Quaternion for each
/// joint orientation to its next counterpart, relative to its parent joint.
extension Skeleton: Codable {
    /// Takes a list of properties and a list of confidences and builds the skeleton with them.
    ///
    /// - Parameters:
    ///     - properties: List of properties respecting the `allProperties` format
    ///     - confidences: List of confidences respecting the `allConfidences` format
    init(properties: [Float], confidences: [Float]) {
        self.init()

        for i in stride(from: 0, to: properties.count, by: 7) {
            self[SkeletonJoint.allCases[i/7]] = Joint(
                properties: Array(properties[i..<(i+7)]),
                confidences: Array(confidences[i..<(i+7)]))
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SkeletonJoint.self)

        self.init()

        for joint in SkeletonJoint.allCases {
            self[joint] = try values.decode(Joint.self, forKey: joint)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SkeletonJoint.self)

        for joint in SkeletonJoint.allCases {
            try container.encode(self[joint], forKey: joint)
        }
    }
}

// MARK: - Accessing the joints
extension Skeleton {
    /// Subscript operator for reading and writing the skeleton joints
    ///
    /// - Parameter joint: The joint to access
    subscript(joint: SkeletonJoint) -> Joint {
        get {
            switch joint {
            case .head: return self.head
            case .neck: return self.neck
            case .leftShoulder: return self.leftShoulder
            case .rightShoulder: return self.rightShoulder
            case .leftElbow: return self.leftElbow
            case .rightElbow: return self.rightElbow
            case .leftHand: return self.leftHand
            case .rightHand: return self.rightHand
            case .torso: return self.torso
            case .leftHip: return self.leftHip
            case .rightHip: return self.rightHip
            case .leftKnee: return self.leftKnee
            case .rightKnee: return self.rightKnee
            case .leftFoot: return self.leftFoot
            case .rightFoot: return self.rightFoot
            }
        }
        set {
            switch joint {
            case .head: self.head = newValue
            case .neck: self.neck = newValue
            case .leftShoulder: self.leftShoulder = newValue
            case .rightShoulder: self.rightShoulder = newValue
            case .leftElbow: self.leftElbow = newValue
            case .rightElbow: self.rightElbow = newValue
            case .leftHand: self.leftHand = newValue
            case .rightHand: self.rightHand = newValue
            case .torso: self.torso = newValue
            case .leftHip: self.leftHip = newValue
            case .rightHip: self.rightHip = newValue
            case .leftKnee: self.leftKnee = newValue
            case .rightKnee: self.rightKnee = newValue
            case .leftFoot: self.leftFoot = newValue
            case .rightFoot: self.rightFoot = newValue
            }
        }
    }
}

// MARK: - Accessing the properties
extension Skeleton {
    /// Number of values in the allProperties and allConfidences arrays
    static var propertiesCount: Int {
        return SkeletonJoint.allCases.count * 7
    }

    /// All the float properties in the skeleton
    ///
    /// [Joint[ Position[ x y z X2d Y2d ], Orientation[ x y z w ] ] * 7]
    ///
    /// - Parameter profile: The device calibration profile
    /// - Returns: An array with all the properties of the skeleton
    func allProperties(usingProfile profile: DeviceCalibrationProfile) -> [Float] {
        var properties = [Float]()
        for joint in SkeletonJoint.allCases {
            properties.append(contentsOf: self[joint].allproperties(usingProfile: profile))
        }

        return properties
    }

    /// All the float confidences for each propety in the skeleton
    ///
    /// [PositionConfidence * 5, OrientationConfidence * 4]
    ///
    /// - Parameter profile: The device calibration profile
    /// - Returns: An array with all the properties of the skeleton
    var allConfidences: [Float] {
        var confidences = [Float]()
        for joint in SkeletonJoint.allCases {
            confidences.append(contentsOf: self[joint].allConfidences)
        }

        return confidences
    }

    /// Gives an array containing all the joints' orientations
    ///
    /// - Returns: All the joints' orientation
    func jointsOrientation() -> [Float] {
        var orientations = [Float]()

        for joint in SkeletonJoint.allCases {
            orientations.append(contentsOf: self[joint].orientation.properties)
        }

        return orientations
    }
}
