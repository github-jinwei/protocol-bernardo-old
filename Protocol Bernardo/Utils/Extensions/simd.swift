//
//  simd.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-10.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

extension double2: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let x = try values.decode(Double.self, forKey: .x)
        let y = try values.decode(Double.self, forKey: .y)
        self.init(x, y)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }

    private enum CodingKeys: String, CodingKey {
        case x, y
    }
}

extension float3: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let x = try values.decode(Float.self, forKey: .x)
        let y = try values.decode(Float.self, forKey: .y)
        let z = try values.decode(Float.self, forKey: .z)
        self.init(x, y, z)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }

    private enum CodingKeys: String, CodingKey {
        case x, y, z
    }
}

extension simd_quatf: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let x = try values.decode(Float.self, forKey: .x)
        let y = try values.decode(Float.self, forKey: .y)
        let z = try values.decode(Float.self, forKey: .z)
        let r = try values.decode(Float.self, forKey: .r)
        self.init(ix: x, iy: y, iz: z, r: r)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vector.x, forKey: .x)
        try container.encode(vector.y, forKey: .y)
        try container.encode(vector.z, forKey: .z)
        try container.encode(vector.w, forKey: .r)
    }

    private enum CodingKeys: String, CodingKey {
        case x, y, z, r
    }
}
