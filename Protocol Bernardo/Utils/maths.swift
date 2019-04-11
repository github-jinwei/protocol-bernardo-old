//
//  maths.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

/// Transforms a degree rotation to radians
///
/// - Parameter degrees: Angle in degrees
/// - Returns: The angle in radians
@inlinable
internal func deg2rad(_ degrees: CGFloat) -> CGFloat {
    return degrees * .pi / CGFloat(180)
}

/// Transforms a degree rotation to radians
///
/// - Parameter degrees: Angle in degrees
/// - Returns: The angle in radians
@inlinable
internal func deg2rad(_ degrees: Float) -> Float {
    return degrees * .pi / 180.0
}


/// Transform a radians rotation in degrees
///
/// - Parameter radians: Angle in radians
/// - Returns: The angle in degrees
@inlinable
internal func rad2deg(_ radians: Float) -> Float {
    return radians * 180.0 / .pi
}


/// Convert a quaternion to a euler angle
///
/// https://github.com/derekhendrickx/KinectMotionCapture/blob/master/kinectbvh.cpp
///
/// - Parameter q: The quaternion
/// - Returns: The quaternion rotation expressed as roll-pitch-yaw (xyz)
internal func quaternionToEuler(_ q: simd_quatf) -> float3 {
    var eulerAngles = float3(0, 0, 0)

    let sqw: Float = q.vector.w * q.vector.w
    let sqx: Float = q.vector.x * q.vector.x
    let sqy: Float = q.vector.y * q.vector.y
    let sqz: Float = q.vector.z * q.vector.z
    let unit: Float = sqx + sqy + sqz + sqw // if normalised is one, otherwise is correction factor
    let test: Float = q.vector.x * q.vector.y + q.vector.z * q.vector.w

    if test > 0.499 * unit { // singularity at north pole
        eulerAngles.x = 2 * atan2(q.vector.x, q.vector.w)
        eulerAngles.y = .pi / 2
        eulerAngles.z = 0
        return eulerAngles
    }

    if (test < -0.499 * unit) { // singularity at south pole
        eulerAngles.x = -2 * atan2(q.vector.x, q.vector.w)
        eulerAngles.y = -.pi / 2
        eulerAngles.z = 0
        return eulerAngles
    }

    eulerAngles.x = atan2(2 * (q.vector.w * q.vector.z + q.vector.x * q.vector.y), 1 - 2 * (sqy + sqz))
    eulerAngles.y = asin(2 * (q.vector.w * q.vector.y - q.vector.z * q.vector.x))
    eulerAngles.z = atan2(2 * (q.vector.w * q.vector.x + q.vector.y * q.vector.z), 1 - 2 * (sqx + sqy))

    return eulerAngles
}
