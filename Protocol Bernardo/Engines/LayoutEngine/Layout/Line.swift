//
//  Line.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Line: Codable {
    var size: Double = 100.0
    
    var weight: Double = 1.0
    
    var position = Point(x: 0.0, y: 0.0)
    
    var orientation: Double = 0.0
}


extension Line {
    convenience init(from line: Line) {
        self.init()
        
        self.size = line.size
        self.weight = line.weight
        self.position = line.position
        self.orientation = line.orientation
    }
}
