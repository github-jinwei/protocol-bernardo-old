//
//  LayoutElementDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

/// A Layout device represent a real-world acquisition device
class LayoutElementDevice: SKNode {
    
    // /////////////////////////
    // MARK: - Device properties
    // var name: String? = "Device"
    
    var type: LayoutElementType = .device
    
    /// Position of the device in the layout. This position represent the device
    /// coordinates origin when it generate users positions
    // var position
    
    /// The device position height.
    var height: Int = 600
    
    /// Orientation of the device along the Z (Vertical) Axis, in degrees
    var orientation: CGFloat = 0 {
        didSet {
            _captationArea.zRotation = deg2rad(self.horizontalFOV / -2) + orientation
        }
    }
    
    /// The horizontal field of view of the device, in degrees
    var horizontalFOV: CGFloat = 70
    
    /// The minimum distance to be from the device to be``` able to be detected (in cm)
    var minimumCaptationDistance: Int = 50
    
    /// The maximum distance to be from the device to be able to be detected (in cm)
    var maximumCaptationDistance: Int = 450
    
    
    // //////////////////////////
    // MARK: - SKNode properties
    
    /// Reference to the parent node
    ///
    /// Reference is weak to prevent circular referencing
    internal weak var _editor: LayoutEditor!
    
    /// The sprite node holding the device image
    internal var _deviceSprite: SKSpriteNode!
    
    /// The shape used to trigger clicks on the device image
    internal var _centerCircle: SKShapeNode!
    
    /// The shape representing the device captation area
    internal var _captationArea: SKShapeNode!
    
    /// The name tag for the device on the scene
    internal var _deviceLabel: SKLabelNode!
    
    /// Tell is the device is currently selected
    internal var _isSelected: Bool = false
}

// MARK: - LayoutElement methods
extension LayoutElementDevice: LayoutElement {
    
}


// //////////////////////
// MARK: - SKNode methods
extension LayoutElementDevice {
    convenience init(withEditor editor: LayoutEditor, withExistingDevice device: Any?) {
        self.init()
        
        self.name = "Device"
        isUserInteractionEnabled = true
        
        _editor = editor
        
        // Build the device sprite node
        _deviceSprite = SKSpriteNode(imageNamed: "Device")
        _deviceSprite.position.y += 3
        _deviceSprite.setScale(0.15)
        _deviceSprite.colorBlendFactor = 1.0
        
        _deviceLabel = SKLabelNode(text: self.name)
        _deviceLabel.horizontalAlignmentMode = .center
        _deviceLabel.verticalAlignmentMode = .center
        _deviceLabel.position.y -= 12
        _deviceLabel.fontSize = 11
        _deviceLabel.fontName = NSFont.systemFont(ofSize: 11, weight: .bold).fontName
        
        _centerCircle = SKShapeNode(circleOfRadius: 25)
        
        // Build the captation area node
        _captationArea = SKShapeNode(path: captationArea())
        _captationArea.zRotation = deg2rad(self.horizontalFOV / -2)
        
        // Give them their idle style
        setIdleAppearance()
        
        // Insert them in the tree
        self.addChild(_centerCircle)
        self.addChild(_captationArea)
        self.addChild(_deviceSprite)
        self.addChild(_deviceLabel)
        
        // And insert ourselves
        _editor.frontLayer.addChild(self)
        
        // Do we represent an existing device ?
        
        // ...
    }
    
    override func mouseDown(with event: NSEvent) {
        // Make sure the clicked event is in the correct area
        guard cursorInTriggerArea(forEvent: event) else {
            markAsIdle()
            return
        }
        
        markAsSelected()
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        guard cursorInTriggerArea(forEvent: event) else {
            markAsIdle()
            return
        }
        
        self.position.x += event.deltaX
        self.position.y -= event.deltaY
    }
    
    internal func markAsSelected() {
        _editor.selectedNode = self
    }
    
    func select() {
        _isSelected = true
        
        // Update appearance to reflect change
        setSelectedAppearance()
    }
    
    internal func markAsIdle() {
        _editor.selectedNode = nil
    }
    
    func deselect() {
        _isSelected = false
        
        // Update appearance to reflect change
        setIdleAppearance()
    }
    
    func remove() {
        // Asks the user before going further obviously
        
        // ...
        
        self.removeAllChildren()
        self.removeFromParent()
    }
}


// /////////////////////
// MARK: - SKNode utils
extension LayoutElementDevice {
    func setIdleAppearance() {
        _deviceSprite.color = NSColor(calibratedWhite: 0, alpha: 0.9)
        _deviceLabel.fontColor = NSColor(calibratedWhite: 0, alpha: 0.8)
        
        _centerCircle.alpha = 0.0
        
        _captationArea.fillColor = NSColor(calibratedWhite: 0, alpha: 0.5)
        _captationArea.strokeColor = NSColor(calibratedWhite: 0, alpha: 0.8)
    }
    
    func setSelectedAppearance() {
        // _deviceSprite.color = NSColor(_highlightColor, alpha: 0.9)
        
        _centerCircle.alpha = 1.0
        _centerCircle.fillColor = NSColor(_highlightColor, alpha: 0.5)
        _centerCircle.strokeColor = NSColor(_highlightColor, alpha: 0.8)
        
        _captationArea.fillColor = NSColor(_highlightColor, alpha: 0.5)
        _captationArea.strokeColor = NSColor(_highlightColor, alpha: 0.8)
    }
    
    /// Gives the CGPath corresponding to the device captation area
    ///
    /// - Returns: A CGPath representing an arc
    func captationArea() -> CGMutablePath {
        let angle = deg2rad(self.horizontalFOV)
        
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero,
                    radius: CGFloat(self.minimumCaptationDistance),
                    startAngle: angle,
                    endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: self.maximumCaptationDistance, y: 0))
        path.addArc(center: CGPoint.zero,
                    radius: CGFloat(self.maximumCaptationDistance),
                    startAngle: 0,
                    endAngle: angle,
                    clockwise: false)
        path.closeSubpath()
        
        return path
    }
    
    /// Tell if the cursor described bhy the given mouse event falls inside the
    /// device trigger areas
    ///
    /// - Parameter event: Mouse event
    /// - Returns: True if the cursor is inside the trigger area, false otherwise
    func cursorInTriggerArea(forEvent event: NSEvent) -> Bool {
        let clickLocationCaptationArea = event.location(in: _captationArea)
        let clickLocationCenterArea = event.location(in: _centerCircle)
        
        if(_captationArea.path!.contains(clickLocationCaptationArea) ||
            _centerCircle.contains(clickLocationCenterArea)) {
            return true
        }
        
        return false
    }
}
