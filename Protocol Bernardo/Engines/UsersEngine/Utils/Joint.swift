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
extension Joint: Codable {
    /// Create a Joint using a property list and a confidences list
    ///
    /// - Parameters:
    ///     - properties: Properties for the joint respecting the `properties` format
    ///     - confidences: Confidences for the joint respecting the `confidences` format
    init(properties: [Float], confidences: [Float]) {
        self.init()

        orientation = simd_quatf(properties: Array(properties[0..<4]))
        orientationConfidence = confidences[0]

        position = float3(Array(properties[4..<7]))
        positionConfidence = confidences[4]
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Decode values
        let           orientation = try values.decode(simd_quatf.self, forKey: .orientation)
        let orientationConfidence = try values.decode(     Float.self, forKey: .orientationConfidence)
        let              position = try values.decode(    float3.self, forKey: .position)
        let    positionConfidence = try values.decode(     Float.self, forKey: .positionConfidence)

        // Create the joint using the decoded values
        self.init(          orientation: orientation,
                  orientationConfidence: orientationConfidence,
                               position: position,
							   position2D: simd_make_float2(0.0, 0.0),
                     positionConfidence: positionConfidence)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(orientation, forKey: .orientation)
        try container.encode(orientationConfidence, forKey: .orientationConfidence)
        try container.encode(position, forKey: .position)
        try container.encode(positionConfidence, forKey: .positionConfidence)
    }

    private enum CodingKeys: CodingKey {
        case orientation,
             orientationConfidence,
             position,
             positionConfidence
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
        return orientation.properties + [pos.x, pos.y, pos.z]
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
        ]
    }
}
