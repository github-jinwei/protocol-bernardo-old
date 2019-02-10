//
//  LayoutElement.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit
import AppKit

protocol LayoutCanvasElement: AnyObject {
    /// The element delegate
    var delegate: LayoutCanvasElementDelegate? { get set }
    
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
    
    /// Tell if the cursor described by the given mouse event falls inside the
    /// device trigger areas
    ///
    /// - Parameter event: Mouse event
    /// - Returns: True if the cursor is inside the trigger area, false otherwise
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool
    
    /// Call on the update part of the frame rendering by the scene
    func update()
}

// MARK: - Default Implementations
extension LayoutCanvasElement {
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        return false
    }
    
    func update() { }
}

// MARK: - Useful methods
extension LayoutCanvasElement {
    /// Gives the highlight color for the current MacOS Style
    internal var _highlightColor: NSColor {
        return NSColor.controlAccentColor
    }
}
