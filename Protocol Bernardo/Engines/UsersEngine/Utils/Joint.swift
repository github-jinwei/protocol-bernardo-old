//
//  Joint.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Joint represent a node on a Skeleton.
///
/// A Joint is defined by its position (in 2D and 3D space) and its rotation, and
/// a confidence value for both.
extension Joint {
    /// Create a Joint using a property list and a confidences list
    ///
    /// - Parameters:
    ///     - properties: Properties for the joint respecting the `properties` format
    ///     - confidences: Confidences for the joint respecting the `confidences` format
    init(properties: [Float], confidences: [Float]) {
        self.init()

        orientation = Quaternion(properties: Array(properties[0..<4]))
        orientationConfidence = confidences[0]

        position = Position(properties: Array(properties[4..<6]))
        orientationConfidence = confidences[4]

    }
}

// MARK: - Accessing Properties
extension Joint {
    /// All the joint properties in the global space in an array
    ///
    /// - Parameter profile: The calibration profile to translate to the global profile
    /// - Returns: All the properties in an array
    func allproperties(usingProfile profile: DeviceCalibrationProfile) -> [Float] {
        let pos = profile.globalCoordinates(forPosition: position)
        return orientation.properties + pos.properties
    }

    /// All the confidence values for the joint properties
    var allConfidences: [Float] {
        return [orientationConfidence,
                orientationConfidence,
                orientationConfidence,
                orientationConfidence,
                positionConfidence,
                positionConfidence,
                positionConfidence,
                positionConfidence,
                positionConfidence,
        ]
    }
}
