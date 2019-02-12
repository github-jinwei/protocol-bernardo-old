//
//  CalibrationDeltas.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-11.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A list of positionning differences betwen two captation devices
struct CalibrationDeltas {
    /// Orientation difference
    var orientation: Float = 0.0
    
    /// X Position difference
    var xPosition: Float = 0.0
    
    /// Y Position difference
    var yPosition: Float = 0.0
    
    /// Height difference
    var height: Float = 0.0
}
