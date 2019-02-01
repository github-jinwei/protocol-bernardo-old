//
//  DevicesLayoutView.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-29.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

// Represent the view holding the spriteKit Scene, primarly used for event handling
class DevicesLayoutView: SKView {
    var editor: LayoutEditor!
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let elements = getElementsAtPoint(forEvent: event)
        
        guard elements.count > 0 else {
            editor.selectedNode = nil
            return
        }
        
        editor.selectedNode = elements.last!
    }
    
    override func mouseUp(with event: NSEvent) {
        editor?.mouseUp(with: event)
        super.mouseUp(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        editor.selectedNode?.mouseDragged(with: event)
        super.mouseDragged(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        
        editor.root.position.x += event.scrollingDeltaX
        editor.root.position.y -= event.scrollingDeltaY
    }
    
    override func magnify(with event: NSEvent) {
        super.magnify(with: event)
        
        // Scale the scene
        let scale = (editor.root.xScale + event.magnification).clamped(to: 0.25...1)
        editor.root.xScale = scale
        editor.root.yScale = scale
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        
        // Simply pass the event to the selected node
        editor?.selectedNode?.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        super.keyUp(with: event)
        
        // Simply pass the event to the selected node
    }
    
    /// Returns the element in the layout of the location event
    ///
    /// - Parameter event:
    /// - Returns: All the elements hit by the event
    internal func getElementsAtPoint(forEvent event: NSEvent) -> [LayoutElement] {
        return editor.elements.filter { element in
            return element.locationInTriggerArea(forEvent: event)
        }
    }
}
