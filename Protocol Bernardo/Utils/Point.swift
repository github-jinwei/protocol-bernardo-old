//
//  Point.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import CoreGraphics

struct Point: Codable {
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    init(_ point: CGPoint) {
        self.x = Double(point.x)
        self.y = Double(point.y)
    }
}
