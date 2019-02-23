//
//  Line.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A line displayed on the layout. May or may not represent a real worl element
class Line: Codable {
    /// The length of the line, in cm
    var size: Double = 100.0
    
    /// The line's weight/width for the representation
    var weight: Double = 1.0
    
    /// The line's position
    var position = Point(x: 0.0, y: 0.0)
    
    /// The line's orientation (in degrees)
    var orientation: Double = 0.0

    /// Convenient init used to duplicate a line
    ///
    /// - Parameter device: An existing line to use as source
    convenience init(from line: Line) {
        self.init()
        
        self.size = line.size
        self.weight = line.weight
        self.position = line.position
        self.orientation = line.orientation
    }
}
