//
//  LayoutElementDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

/// A Layout device represent a real-world acquisition device
class LayoutEditorDevice: SKNode {
    
    /// The device this node is representing
    var device: Device!
    
    // ////////////////////////////////
    // MARK: - Device properties remap
    
    override var name: String? {
        didSet {
            device.name = name
            _deviceLabel?.text = name
        }
    }
    
    /// Position of the device in the layout. This position represent the device
    /// coordinates origin when it generate users positions
    //  var position: CGPoint
    
    /// The device position height.
    var height: CGFloat = 60.0 {
        didSet {
            device.height = height
        }
    }
    
    /// Orientation of the device along the Z (Vertical) Axis, in degrees
    var orientation: CGFloat = 0 {
        didSet {
            device.orientation = orientation
            _captationArea.zRotation = deg2rad(self.horizontalFOV / -2 + orientation)
        }
    }
    
    /// The horizontal field of view of the device, in degrees
    var horizontalFOV: CGFloat = 70 {
        didSet {
            device.horizontalFOV = horizontalFOV
            _captationArea.path = captationArea()
            _captationArea.zRotation = deg2rad(self.horizontalFOV / -2 + orientation)
        }
    }
    
    /// The minimum distance to be from the device to be``` able to be detected (in cm)
    var minimumCaptationDistance: CGFloat = 50 {
        didSet {
            device.minimumCaptationDistance = minimumCaptationDistance
            _captationArea.path = captationArea()
        }
    }
    
    /// The maximum distance to be from the device to be able to be detected (in cm)
    var maximumCaptationDistance: CGFloat = 450{
        didSet {
            device.maximumCaptationDistance = maximumCaptationDistance
            _captationArea.path = captationArea()
        }
    }
    
    
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
    
    
    // ////////////////////////////////
    // MARK: - Sidebar Properties view
    
    /// Reference to the device parameters view when it is available
    internal lazy var _parametersController: PBLayoutDevicePropertiesController = {
        let storyboard = NSStoryboard(name: "LayoutEditor", bundle: nil)
        var controller = storyboard.instantiateController(withIdentifier: "deviceParametersController") as! PBLayoutDevicePropertiesController
        controller.device = self
        
        return controller
    }()
}


// /////////////////////
// MARK: - LayoutElement
extension LayoutEditorDevice: LayoutEditorElement {
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
extension LayoutEditorDevice {
    convenience init(withEditor editor: LayoutEditor, forDevice device: Device) {
        self.init()
        
        self.device = device
        
        self.name = "Device"
        isUserInteractionEnabled = false
        
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
}


// ///////////////////
// MARK: - User events
extension LayoutEditorDevice {
    override func mouseDragged(with event: NSEvent) {
        guard locationInTriggerArea(forEvent: event) else {
            markAsIdle()
            super.mouseDragged(with: event)
            return
        }
        
        self.position.x += (event.deltaX / _editor.root.xScale)
        self.position.y -= (event.deltaY / _editor.root.yScale)
        
        updatePositionOnParameters()
        device.position = position
    }
    
    override func keyDown(with event: NSEvent) {
        // Make sure we only aknowledge keyboard events when we are selected
        guard _isSelected else {
            return
        }
        
        let translateAmount:CGFloat = 1 * (event.modifierFlags.contains(.shift) ? 10 : 1)
        
        switch event.keyCode {
        case Keycode.delete: delete()
        case Keycode.upArrow: position.y += translateAmount
        case Keycode.downArrow: position.y -= translateAmount
        case Keycode.rightArrow: position.x += translateAmount
        case Keycode.leftArrow: position.x -= translateAmount
        default: return
        }
        
        updatePositionOnParameters()
        device.position = position
    }
}

    
// ////////////////////
// MARK: - Device state
extension LayoutEditorDevice {
    /// Change the device state to selected
    internal func markAsSelected() {
        _editor.selectedNode = self
    }
    
    /// Update the device state to reflect is selected state.
    /// You should not called this method directly. Use `markAsSelected` instead.
    func select() {
        _isSelected = true
        
        // Update appearance to reflect change
        setSelectedAppearance()
    }
    
    /// Change the device state to idle
    internal func markAsIdle() {
        _editor.selectedNode = nil
    }
    
    /// Update the device state to reflect is deselected state.
    /// You should not called this method directly. Use `markAsIdle` instead.
    func deselect() {
        _isSelected = false
        
        // Update appearance to reflect change
        setIdleAppearance()
    }

    /// Delete the device, removes it from the layout and fron the view
    func delete() {
        // Asks the user before going further obviously
        
        // ...
        
        markAsIdle()
        _editor.removeDevice(element: self)
        
        self.removeAllChildren()
        self.removeFromParent()
    }
}


// /////////////////////
// MARK: - SKNode utils
extension LayoutEditorDevice {
    /// Update the device appearance to reflect its idle state
    ///
    /// This also reflects the default state of the device on the scene
    func setIdleAppearance() {
        _deviceSprite.color = NSColor(calibratedWhite: 0, alpha: 0.9)
        _deviceLabel.fontColor = NSColor(calibratedWhite: 0, alpha: 0.8)
        
        _centerCircle.alpha = 0.0
        
        _captationArea.fillColor = NSColor(calibratedWhite: 0, alpha: 0.5)
        _captationArea.strokeColor = NSColor(calibratedWhite: 0, alpha: 0.8)
    }
    
    /// Update the device appearance to reflect its selected state
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
    
    /// Tell if the cursor described by the given mouse event falls inside the
    /// device trigger areas
    ///
    /// - Parameter event: Mouse event
    /// - Returns: True if the cursor is inside the trigger area, false otherwise
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        let clickLocationCaptationArea = event.location(in: _captationArea)
        let clickLocationCenterArea = event.location(in: _centerCircle)
        
        if(_captationArea.path!.contains(clickLocationCaptationArea) ||
            _centerCircle.contains(clickLocationCenterArea)) {
            return true
        }
        
        return false
    }
}
