//
//  Quaternion.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

/// A Quaternion represent a 3D rotation defined using 4 parameters
extension simd_quatf {
    /// Create a Quaternion using a list of properties
    ///
    /// - Parameters:
    ///     - properties: List of properties for the quaternion using the format [x y z w]
    init(properties: [Float]) {
        self.init(vector: float4(properties))
    }

    /// The quaternion properties in an array as [x y z w]
    var properties: [Float] {
        return [self.vector.x, self.vector.y, self.vector.z, self.vector.w]
    }
}
