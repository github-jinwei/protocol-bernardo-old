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
