//
//  Point.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import CoreGraphics

/// Represent a 2D Point
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

extension Point {
    /// + Operator to add the values of two Point
    ///
    /// - Parameters:
    ///   - left: _
    ///   - right: _
    /// - Returns: A new point consisting of the sum of the two others
    static func + (left: Point, right: Point) -> Point {
        return Point(x: left.x + right.x, y: left.y + right.y)
    }
}
