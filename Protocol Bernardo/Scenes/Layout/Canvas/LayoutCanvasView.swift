//
//  LayoutCanvasView.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-29.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

// Represent the view holding the spriteKit Scene, primarly used for event handling
class LayoutCanvasView: SKView {
    var canvas: LayoutCanvas!
    
    override func mouseDown(with event: NSEvent) {
        let elements = getElementsAtPoint(forEvent: event)
        
        guard elements.count > 0 else {
            canvas.selectedNode = nil
            return
        }
        
        canvas.selectedNode = elements.last!
    }
    
    override func mouseUp(with event: NSEvent) {
        canvas?.mouseUp(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        canvas.selectedNode?.mouseDragged(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        
        canvas.root.position.x += event.scrollingDeltaX
        canvas.root.position.y -= event.scrollingDeltaY
    }
    
    override func magnify(with event: NSEvent) {
        // Scale the scene
        let scale = (canvas.root.xScale + event.magnification).clamped(to: 0.25...1.25)
        canvas.root.xScale = scale
        canvas.root.yScale = scale
    }
    
    override func keyDown(with event: NSEvent) {
        // Make sure the canvas is editable
        guard canvas.isEditable else { return }
        
        // Simply pass the event to the selected node
        canvas?.selectedNode?.keyDown(with: event)
    }
    
    /// Returns the element in the layout of the location event
    ///
    /// - Parameter event:
    /// - Returns: All the elements hit by the event
    internal func getElementsAtPoint(forEvent event: NSEvent) -> [LayoutCanvasElement] {
        let frontElements = canvas.frontElements.filter { element in
            return element.locationInTriggerArea(forEvent: event)
        }
        
        // Return here if we found a node, or if the canvas isn't editable
        if frontElements.count > 0 || !canvas.isEditable {
            return frontElements
        }
        
        return canvas.backElements.filter { element in
            return element.locationInTriggerArea(forEvent: event)
        }
    }
}
