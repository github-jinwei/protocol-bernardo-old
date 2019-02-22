//
//  Position.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd


extension Position {
    var properties: [Float] {
        return [x, y, z, x2D, y2D]
    }

    init(properties: [Float]) {
        self.init()
        
        self.x = properties[0]
        self.y = properties[1]
        self.z = properties[2]
        self.x2D = properties[3]
        self.y2D = properties[3]
    }
}

extension Position {

    /// Addition operator overload
    /// Adds the properties of the left component by the corresponding ones
    /// on the right components
    ///
    /// - Parameters:
    ///   - left: _
    ///   - right: _
    /// - Returns: _
    static public func + (left: Position, right: Position) -> Position {
        var pos = Position()

        pos.x = left.x + right.x
        pos.y = left.y + right.y
        pos.z = left.z + right.z

        pos.x2D = left.x2D + right.x2D
        pos.y2D = left.y2D + right.y2D

        return pos
    }

    /// Substraction operator overload
    /// Divides the properties of the left component by the corresponding ones
    /// on the right components
    ///
    /// - Parameters:
    ///   - left: _
    ///   - right: _
    /// - Returns: _
    static public func - (left: Position, right: Position) -> Position {
        var pos = Position()

        pos.x = left.x - right.x
        pos.y = left.y - right.y
        pos.z = left.z - right.z

        pos.x2D = left.x2D - right.x2D
        pos.y2D = left.y2D - right.y2D

        return pos
    }

    /// Multiply operator overload
    /// Multiply the properties of the left component by the corresponding ones
    /// on the right components
    ///
    /// - Parameters:
    ///   - left: _
    ///   - right: _
    /// - Returns: _
    static public func * (left: Position, right: Float) -> Position {
        var pos = Position()

        pos.x = left.x * right
        pos.y = left.y * right
        pos.z = left.z * right

        pos.x2D = left.x2D * right
        pos.y2D = left.y2D * right

        return pos
    }
    
    /// Dividing operator overload
    /// Divides the properties of the left component by the corresponding ones
    /// on the right components
    ///
    /// - Parameters:
    ///   - left: _
    ///   - right: _
    /// - Returns: _
    static public func / (left: Position, right: Float) -> Position {
        var pos = Position()
        
        pos.x = left.x / right
        pos.y = left.y / right
        pos.z = left.z / right
        
        pos.x2D = left.x2D / right
        pos.y2D = left.y2D / right
        
        return pos
    }
    
    /// Gives the angle betwee the current position as a vector, and the given one as a vector
    ///
    /// - Parameter position: _
    /// - Returns: Angle between the two vectors
    public func angle(with position: Position) -> Float {
        let vec1 = vector3(self.x, self.y, self.z)
        let vec2 = vector3(position.x, position.y, position.z)
        
        let dotProduct = dot(normalize(vec1), normalize(vec2))
        return acos(dotProduct)
    }
    
    /// Gives the distance between this position and the given one
    ///
    /// - Parameter dist: _
    /// - Returns: _
    func distance(from dist: Position) -> Float {
        return sqrtf(powf(self.x - dist.x, 2) +
                     powf(self.y - dist.y, 2) +
                     powf(self.z - dist.z, 2))
    }
}
