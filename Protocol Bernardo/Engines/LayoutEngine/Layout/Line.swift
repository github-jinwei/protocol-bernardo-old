//
//  Line.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Line: Codable {
    var size: CGFloat = 100.0
    
    var weight: CGFloat = 1.0
    
    var position = CGPoint(x: 0, y: 0)
    
    var orientation: CGFloat = 0.0
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
