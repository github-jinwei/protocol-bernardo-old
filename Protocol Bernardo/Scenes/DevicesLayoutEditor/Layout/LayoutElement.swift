//
//  LayoutElement.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit
import AppKit

protocol LayoutElement: AnyObject {
    /// Name of the element
    var name: String? { get set }
    
    /// Type of the element
    var type: LayoutElementType { get }
    
    /// Called by a user event to mark the element as selected
    func select()
    
    /// Called by a user event to deselect the element
    func deselect()
    
    /// Allows the element to receive keyDown events
    ///
    /// - Parameter event: a KeyDown event
    func keyDown(with event: NSEvent)
    
    func mouseDragged(with event: NSEvent)
    
    func getParametersController() -> NSViewController
    
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool
}

extension LayoutElement {
    internal var _highlightColor: NSColor {
        return NSColor.selectedMenuItemColor
    }
    
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        return false
    }
}
