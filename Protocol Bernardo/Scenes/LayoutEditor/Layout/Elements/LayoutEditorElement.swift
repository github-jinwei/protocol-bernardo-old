//
//  LayoutElement.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit
import AppKit

protocol LayoutEditorElement: AnyObject {
    /// Name of the element
    var name: String? { get set }
    
    /// Called by a user event to mark the element as selected
    func select()
    
    /// Called by a user event to deselect the element
    func deselect()
    
    /// Allows the element to receive keyDown events
    ///
    /// - Parameter event: a KeyDown event
    func keyDown(with event: NSEvent)
    
    /// Allos the user to drag the element around
    ///
    /// - Parameter event:
    func mouseDragged(with event: NSEvent)
    
    /// Gives the viewController holding the parameters view for the element
    ///
    /// - Returns:
    func getParametersController() -> NSViewController
    
    /// Tell if the location of the given event hit the element
    ///
    /// - Parameter event:
    /// - Returns: true if hit, false otherwise
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool
}

extension LayoutEditorElement {
    internal var _highlightColor: NSColor {
        return NSColor.selectedMenuItemColor
    }
    
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        return false
    }
}
