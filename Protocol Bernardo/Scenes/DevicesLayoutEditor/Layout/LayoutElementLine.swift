//
//  LayoutElementLine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Layout Line is used to adds marks on the layout and ease its comprehension.
class LayoutElementLine: LayoutElement {
    func select() {
        
    }
    
    func deselect() {
        
    }
    
    var name: String = "Line"
    
    var type: LayoutElementType = .line
    
    /// The line weight
    var weight: Int = 1
    
    /// The line starting point of the line
    var startPoint = PBPoint(x: -50, y: 0)
    
    /// The ending point of the line
    var endPoint = PBPoint(x: 50, y: 0)
}
