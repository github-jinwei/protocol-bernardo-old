//
//  LayoutElement.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

protocol LayoutElement: AnyObject {
    /// Type of the element
    var type: LayoutElementType { get }
    
    /// Called by a user event to mark the element as selected
    func select()
    
    /// Called by a user event to deselect the element
    func deselect()
}

extension LayoutElement {
    internal var _highlightColor: NSColor {
        return NSColor.selectedMenuItemColor
    }
}
