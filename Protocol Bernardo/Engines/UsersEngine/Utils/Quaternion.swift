//
//  Quaternion.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Quaternion represent a 3D rotation defined using 4 parameters
extension Quaternion {
    /// Create a Quaternion using a list of properties
    ///
    /// - Parameters:
    ///     - properties: List of properties for the quaternion using the format [x y z w]
    init(properties: [Float]) {
        self.init()

        self.x = properties[0]
        self.y = properties[1]
        self.z = properties[2]
        self.w = properties[3]
    }

    /// The quaternion properties in an array as [x y z w]
    var properties: [Float] {
        return [x, y, z, w]
    }
}
