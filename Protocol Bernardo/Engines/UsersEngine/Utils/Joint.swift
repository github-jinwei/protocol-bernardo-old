//
//  Joint.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension Joint {
    func properties(usingProfile profile: DeviceCalibrationProfile) -> [Float] {
        let pos = profile.globalCoordinates(forPosition: position)
        return orientation.properties + pos.properties
    }

    var confidences: [Float] {
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

    init(properties: [Float], confidences: [Float]) {
        self.init()
        
        orientation = Quaternion(properties: Array(properties[0..<4]))
        orientationConfidence = confidences[0]

        position = Position(properties: Array(properties[4..<6]))
        orientationConfidence = confidences[4]

    }
}
