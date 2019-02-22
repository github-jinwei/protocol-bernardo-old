//
//  Skeleton.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
extension Skeleton {
    /// Subscript operator for reading and writing the skeleton joints
    ///
    /// - Parameter joint: <#joint description#>
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


extension Skeleton {
    /// Number of values in the allProperties and allConfidences arrays
    static var propertiesCount: Int {
        return SkeletonJoint.allCases.count * 9
    }

    /// All the float properties in the skeleton
    ///
    /// [Joint[Position[xyzX2dU2d], Orientation[xyzw]]*9]
    ///
    /// - Parameter profile: The device calibration profile
    /// - Returns: An array with all the properties of the skeleton
    func allProperties(usingProfile profile: DeviceCalibrationProfile) -> [Float] {
        var properties = [Float]()
        for joint in SkeletonJoint.allCases {
            properties.append(contentsOf: self[joint].properties(usingProfile: profile))
        }

        return properties
    }

    /// All the float confidences in the skeleton
    ///
    /// [PositionConfidence*5, OrientationConfidence*4]
    ///
    /// - Parameter profile: The device calibration profile
    /// - Returns: An array with all the properties of the skeleton
    var allConfidences: [Float] {
        var confidences = [Float]()
        for joint in SkeletonJoint.allCases {
            confidences.append(contentsOf: self[joint].confidences)
        }

        return confidences
    }

    init(properties: [Float], confidences: [Float]) {
        self.init()
        
        for i in stride(from: 0, to: properties.count, by: 9) {
            self[SkeletonJoint.allCases[i]] = Joint(properties: Array(properties[(i*9)..<((i+1)*9)]),
                                                    confidences: Array(confidences[(i*9)..<((i+1)*9)]))
        }
    }
}
