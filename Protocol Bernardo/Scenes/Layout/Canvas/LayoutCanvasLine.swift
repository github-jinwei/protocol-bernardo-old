//
//  LayoutElementLine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

/// A Layout Line is used to adds marks on the layout and ease its comprehension.
class LayoutCanvasLine: SKNode {
    
    /// The line this node is reprenseting
    weak var line: Line!
    
    var delegate: LayoutCanvasElementDelegate?
    
    
    // ////////////////////////////////
    // MARK: - Line properties remap
    
    /// The length of the line
    var size: CGFloat = 100.0 {
        didSet {
            line.size = Double(size)
            
            // Update the shape
            _lineShape.path = getLineRectPath(width: size, height: weight)
            _clickableArea.path = getLineRectPath(width: size,
                                                  height: (weight + 10).clamped(to: weight...10))
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    override var position: CGPoint {
        didSet {
            line.position = Point(position)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    var weight: CGFloat = 1.0 {
        didSet {
            line.weight = Double(weight)
            
            // Update the shape
            _lineShape.path = getLineRectPath(width: size, height: weight)
            _clickableArea.path = getLineRectPath(width: size,
                                                  height: weight+5)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    var orientation: CGFloat = 0.0 {
        didSet {
            line.orientation = Double(orientation)
            
            self.zRotation = deg2rad(orientation)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    
    // //////////////////////////
    // MARK: - SKNode properties
    
    /// Reference to the parent node
    ///
    /// Reference is weak to prevent circular referencing
    internal weak var _canvas: LayoutCanvas!
    
    /// The actual line being displayed
    internal var _lineShape: SKShapeNode!
    
    /// The clickable area as the line may be too thin for easy manipulation
    internal var _clickableArea: SKShapeNode!
    
    /// Tell if the line is currently selected
    internal var _isSelected: Bool = false
    
    
    // ////////////////////////////////
    // MARK: - Sidebar Properties view
    
    /// Reference to the device parameters view when it is available
    internal lazy var _parametersController: PBLayoutCanvasLinePropertiesController = {
        let storyboard = NSStoryboard(name: "Layout", bundle: nil)
        var controller = storyboard.instantiateController(withIdentifier: "lineParametersController") as! PBLayoutCanvasLinePropertiesController
        controller.line = self
        
        return controller
    }()
}


// /////////////////////
// MARK: - LayoutElement
extension LayoutCanvasLine: LayoutCanvasElement {
    /// Returns the controller allowing for fine tuning of the
    /// device parameter
    ///
    /// - Returns: A view controller
    func getParametersController() -> NSViewController {
        return _parametersController
    }
    
    /// Update the position values for the device on the parameters view
    func updatePositionOnParameters() {
        _parametersController.set(position: position)
    }
}


// ///////////////////
// MARK: - Initializer
extension LayoutCanvasLine {
    convenience init(onCanvas canvas: LayoutCanvas,
                     forLine line: Line) {
        self.init()
        
        _canvas = canvas
        
        // Set the represented line
        self.line = line
        
        // Copy the values from the line to ourselves
        self.size = CGFloat(line.size)
        self.weight = CGFloat(line.weight)
        self.position = CGPoint(line.position)
        self.orientation = CGFloat(line.orientation)
        
        // Set up the node
        isUserInteractionEnabled = false
        
        // Build the line sprite node
        let linePath = getLineRectPath(width: size,
                                       height: weight)
        _lineShape = SKShapeNode(path: linePath)
        
        // Build the clickable area sprite node
        let clickablePath = getLineRectPath(width: size,
                                            height: weight + 10)
        _clickableArea = SKShapeNode(path: clickablePath)
        _clickableArea.alpha = 0.0
        
        setIdleAppearance()
        
        self.addChild(_lineShape)
        self.addChild(_clickableArea)
        
        // And insert ourselves
        _canvas.backLayer.addChild(self)
    }
    
    /// Duplicate the current node, and insert it in the layout and the scene
    internal func duplicate() {
        let newLine = Line(from: line)
        
        _canvas.layout.decorations.append(newLine)
        _canvas.createNodeForExistingLine(newLine)
    }
}


// ///////////////////
// MARK: - User events
extension LayoutCanvasLine {
    override func mouseDragged(with event: NSEvent) {
        // Check with our delegate if we can edit the node
        guard delegate?.elementCanBeEdited(self) ?? false else {
            return
        }
        
        // Make sure the events concerns us
        guard locationInTriggerArea(forEvent: event) else {
            markAsIdle()
            super.mouseDragged(with: event)
            return
        }
        
        // Adjust the node position accordingly
        self.position.x += (event.deltaX / _canvas.root.xScale)
        self.position.y -= (event.deltaY / _canvas.root.yScale)
        
        // Update the represented device and the parameters view
        updatePositionOnParameters()
        
        // Tell our delegate we got updated
        delegate?.elementDidChange(self)
    }
    
    override func keyDown(with event: NSEvent) {
        // Check with our delegate if we can edit the node
        guard delegate?.elementCanBeEdited(self) ?? false else {
            return
        }
        
        // Make sure we only aknowledge keyboard events when we are selected
        guard _isSelected else {
            return
        }
        
        // Act according to the pressed key
        switch event.keyCode {
        case Keycode.delete: delete()
        case Keycode.upArrow: translateWithEvent(event)
        case Keycode.downArrow: translateWithEvent(event)
        case Keycode.rightArrow: translateWithEvent(event)
        case Keycode.leftArrow: translateWithEvent(event)
        case Keycode.d:
            if event.modifierFlags.contains(.command) {
                duplicate()
            }
        default: break
        }
    }
    
    /// Translate the node by the amount specified by the given MouseDragged event
    ///
    /// - Parameter event:
    internal func translateWithEvent(_ event: NSEvent) {
        let translateAmount:CGFloat = 1 * (event.modifierFlags.contains(.shift) ? 10 : 1)
        
        switch event.keyCode {
        case Keycode.upArrow: position.y += translateAmount
        case Keycode.downArrow: position.y -= translateAmount
        case Keycode.rightArrow: position.x += translateAmount
        case Keycode.leftArrow: position.x -= translateAmount
        default: break
        }
        
        updatePositionOnParameters()
        
        delegate?.elementDidChange(self)
    }
}
    
// ////////////////////
// MARK: - Device state
extension LayoutCanvasLine {
    /// Change the device state to selected
    internal func markAsSelected() {
        _canvas.selectedNode = self
    }
    
    func select() {
        _isSelected = true
        
        // Update appearance to reflect change
        setSelectedAppearance()
    }
    
    /// Change the device state to idle
    internal func markAsIdle() {
        _canvas.selectedNode = nil
    }
    
    func deselect() {
        _isSelected = false
        
        // Update appearance to reflect change
        setIdleAppearance()
    }
    
    /// Delete the device, removes it from the layout and fron the view
    func delete() {
        // Asks the user before going further obviously
        
        let confirmModal = NSAlert()
        confirmModal.alertStyle = .warning
        confirmModal.messageText = "Are you sure you want to delete this device ?"
        confirmModal.addButton(withTitle: "Delete Device")
        confirmModal.addButton(withTitle: "Cancel")
        
        confirmModal.beginSheetModal(for: _canvas._sceneView.window!) { response in
            guard response == NSApplication.ModalResponse.alertFirstButtonReturn else {
                // Alert was canceled, do nothing
                return
            }
            
            self.delegate?.elementWillBeRemoved(self)
            
            self.markAsIdle()
            self._canvas.remove(line: self)
            
            self.removeAllChildren()
            self.removeFromParent()
        }
    }
}


// /////////////////////
// MARK: - SKNode utils
extension LayoutCanvasLine {
    /// Update the device appearance to reflect its idle state
    ///
    /// This also reflects the default state of the device on the scene
    func setIdleAppearance() {
        _lineShape.fillColor = NSColor(calibratedWhite: 0, alpha: 0.8)
        _lineShape.strokeColor = NSColor(calibratedWhite: 0, alpha: 0.8)
    }
    
    /// Update the device appearance to reflect its selected state
    func setSelectedAppearance() {
        _lineShape.fillColor = NSColor(_highlightColor, alpha: 0.8)
        _lineShape.strokeColor = NSColor(_highlightColor, alpha: 0.8)
    }
    
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        let clickLocationClickableArea = event.location(in: _clickableArea)
        
        if _clickableArea.path!.contains(clickLocationClickableArea) {
            return true
        }
        
        return false
    }
    
    func getLineRectPath(width: CGFloat, height: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        path.addRect(CGRect(x: width / -2.0,
                            y: height / -2.0,
                            width: width,
                            height: height))
        return path
    }
}
