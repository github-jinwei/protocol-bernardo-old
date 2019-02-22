//
//  Quaternion.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension Quaternion {
    var properties: [Float] {
        return [x, y, z, w]
    }

    init(properties: [Float]) {
        self.init()
        
        self.x = properties[0]
        self.y = properties[1]
        self.z = properties[2]
        self.w = properties[3]
    }
}

extension Quaternion {
    static func + (_ left: Quaternion, _ right: Quaternion) -> Quaternion {
        var quaternion = Quaternion()
        quaternion.x = left.x + right.x;
        quaternion.y = left.y + right.y;
        quaternion.z = left.z + right.z;
        quaternion.w = left.w + right.w;

        return quaternion
    }

    static func * (_ left: Quaternion, _ right: Float) -> Quaternion {
        var quaternion = Quaternion()
        quaternion.x = left.x * right;
        quaternion.y = left.y * right;
        quaternion.z = left.z * right;
        quaternion.w = left.w * right;

        return quaternion
    }

    static func / (_ left: Quaternion, _ right: Float) -> Quaternion {
        var quaternion = Quaternion()
        quaternion.x = left.x / right;
        quaternion.y = left.y / right;
        quaternion.z = left.z / right;
        quaternion.w = left.w / right;

        return quaternion
    }
}
