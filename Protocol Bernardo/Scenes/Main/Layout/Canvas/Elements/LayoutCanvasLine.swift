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
    
    /// Reference to the delegate
    weak var delegate: LayoutCanvasElementDelegate!

    // ////////////////////////////////
    // MARK: - Line properties remap
    
    /// The length of the line
    var size: CGFloat = 100.0 {
        didSet {
            line.size = Double(size)
            
            // Update the shape
            lineShape.path = getLineRectPath(width: size, height: weight)
            clickableArea.path = getLineRectPath(width: size,
                                                  height: (weight + 10).clamped(to: weight...10))
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    override var position: CGPoint {
        didSet {
            line.position = double2(Double(position.x), Double(position.y))
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    var weight: CGFloat = 1.0 {
        didSet {
            line.weight = Double(weight)
            
            // Update the shape
            lineShape.path = getLineRectPath(width: size, height: weight)
            clickableArea.path = getLineRectPath(width: size,
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
    
    /// The actual line being displayed
    private var lineShape: SKShapeNode!
    
    /// The clickable area as the line may be too thin for easy manipulation
    private var clickableArea: SKShapeNode!
    
    /// Tell if the line is currently selected
    var isSelected: Bool = false

    // ////////////////////////////////
    // MARK: - Sidebar Properties view
    
    /// Reference to the device parameters view when it is available
    private lazy var parametersController: LayoutLinePropertiesViewController = {
		let controller: LayoutLinePropertiesViewController = NSNib.make(fromNib: "Layout", owner: nil)
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
        return parametersController
    }
    
    /// Update the position values for the device on the parameters view
    func updatePositionOnParameters() {
        parametersController.set(position: position)
    }

    func deleteActions() {
        removeAllChildren()
        removeFromParent()
    }
}

// ///////////////////
// MARK: - Initializer
extension LayoutCanvasLine {
    convenience init(onCanvas canvas: LayoutViewController,
                     forLine line: Line) {
        self.init()
        
        // Set the represented line
        self.line = line
        
        // Copy the values from the line to ourselves
        self.size = CGFloat(line.size)
        self.weight = CGFloat(line.weight)
        self.position = CGPoint(x: line.position.x, y: line.position.y)
        self.orientation = CGFloat(line.orientation)
        self.zRotation = deg2rad(orientation)
        
        // Set up the node
        isUserInteractionEnabled = false
        
        // Build the line sprite node
        let linePath = getLineRectPath(width: size,
                                       height: weight)
        lineShape = SKShapeNode(path: linePath)
        
        // Build the clickable area sprite node
        let clickablePath = getLineRectPath(width: size,
                                            height: weight + 10)
        clickableArea = SKShapeNode(path: clickablePath)
        clickableArea.alpha = 0.0
        
        setIdleAppearance()
        
        self.addChild(lineShape)
        self.addChild(clickableArea)
        
        // And insert ourselves
        canvas.backLayer.addChild(self)
    }
    
    /// Duplicate the current node, and insert it in the layout and the scene
    internal func duplicate() {
        delegate.duplicateLineElement(self)
//        let newLine = Line(from: line)
//
//        layoutView.layout.decorations.append(newLine)
//        layoutView.createNodeForExistingLine(newLine)
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

        let scale = delegate.canvasRootNode().xScale
        
        // Adjust the node position accordingly
        self.position.x += (event.deltaX / scale)
        self.position.y -= (event.deltaY / scale)
        
        // Update the represented device and the parameters view
        updatePositionOnParameters()
        
        // Tell our delegate we got updated
        delegate?.elementDidChange(self)
    }
    
    override func keyDown(with event: NSEvent) {
        // Check with our delegate if we can edit the node
        guard (delegate?.elementCanBeEdited(self) ?? false) && isSelected else {
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
        let translateAmount: CGFloat = 1 * (event.modifierFlags.contains(.shift) ? 10 : 1)
        
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

// //////////////////
// MARK: - Appearance
extension LayoutCanvasLine {
    func set(appearance: LayoutCanvasElementAppearance) {
        switch appearance {
        case .idle:
            setIdleAppearance()
        case .selected:
            setSelectedAppearance()
        }
    }

    /// Update the device appearance to reflect its idle state
    ///
    /// This also reflects the default state of the device on the scene
    private func setIdleAppearance() {
        lineShape.fillColor = NSColor(calibratedWhite: 0, alpha: 0.8)
        lineShape.strokeColor = NSColor(calibratedWhite: 0, alpha: 0.8)
    }
    
    /// Update the device appearance to reflect its selected state
    private func setSelectedAppearance() {
        lineShape.fillColor = NSColor(highlightColor, alpha: 0.8)
        lineShape.strokeColor = NSColor(highlightColor, alpha: 0.8)
    }
}

// /////////////////////
// MARK: - SKNode utils
extension LayoutCanvasLine {
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        let clickLocationClickableArea = event.location(in: clickableArea)
        
        if clickableArea.path!.contains(clickLocationClickableArea) {
            return true
        }
        
        return false
    }
    
    /// Returns a rectangle CGMutablePath using the provided parameters
    ///
    /// - Parameters:
    ///   - width: The rectangle's width
    ///   - height: The rectangle's height
    /// - Returns: The rectangle's path
    func getLineRectPath(width: CGFloat, height: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()
        path.addRect(CGRect(x: width / -2.0,
                            y: height / -2.0,
                            width: width,
                            height: height))
        return path
    }
}
