//
//  CalibrationDeltas.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-11.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A list of positionning differences betwen two captation devices
struct CalibrationDeltas: Codable {
    /// Orientation difference
    var orientation: Float? = nil
    
    /// X Position difference (in mm)
    var xPosition: Float = 0.0
    
    /// Y Position difference (in mm)
    var yPosition: Float = 0.0
    
    /// Height difference (in mm)
    var height: Float = 0.0
}
