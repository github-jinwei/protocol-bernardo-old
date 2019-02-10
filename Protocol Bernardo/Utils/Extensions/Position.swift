//
//  Position.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension Position {
    static public func / (left: Position, right: Float) -> Position {
        var pos = Position()
        
        pos.x = left.x / right
        pos.y = left.y / right
        pos.z = left.z / right
        
        pos.x2D = left.x2D / right
        pos.y2D = left.y2D / right
        
        return pos
    }
    
    func distance(from dist: Position) -> Float {
        return sqrtf(powf(self.x - dist.x, 2) +
                     powf(self.y - dist.y, 2) +
                     powf(self.z - dist.z, 2))
    }
}
