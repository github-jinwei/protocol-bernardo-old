//
//  maths.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Transforms a degree rotation to radians
///
/// - Parameter degrees: Angle in degrees
/// - Returns: The angle in radians
internal func deg2rad(_ degrees: CGFloat) -> CGFloat {
    return degrees * .pi / CGFloat(180)
}

/// Transforms a degree rotation to radians
///
/// - Parameter degrees: Angle in degrees
/// - Returns: The angle in radians
internal func deg2rad(_ degrees: Float) -> Float {
    return degrees * .pi / 180.0
}


/// Transform a radians rotation in degrees
///
/// - Parameter radians: Angle in radians
/// - Returns: The angle in degrees
internal func rad2deg(_ radians: Float) -> Float {
    return radians * 180.0 / .pi
}


/// Returns the absolute value of the given position
///
/// - Parameter position: _
/// - Returns: _
//internal func abs(_ position: Position) -> Position {
//    var pos = Position()
//    pos.x = abs(position.x)
//    pos.y = abs(position.y)
//    pos.z = abs(position.z)
//
//    pos.x2D = abs(position.x2D)
//    pos.y2D = abs(position.y2D)
//
//    return pos
//}
