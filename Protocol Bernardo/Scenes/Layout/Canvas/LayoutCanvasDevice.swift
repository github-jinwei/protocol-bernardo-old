//
//  LayoutCanvasDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

/// A Layout device represent a real-world acquisition device
class LayoutCanvasDevice: SKNode {
    
    /// The device this node is representing
    weak var device: Device!
    
    weak var delegate: LayoutCanvasElementDelegate?
    
    // ////////////////////////////////
    // MARK: - Device properties remap
    
    override var name: String? {
        didSet {
            device.name = name!
            _deviceLabel?.text = name
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    override var position: CGPoint {
        didSet {
            device.position = Point(position)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    /// The device position height.
    var height: CGFloat = 60.0 {
        didSet {
            device.height = Double(height)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    /// Orientation of the device along the Z (Vertical) Axis, in degrees
    var orientation: CGFloat = 0 {
        didSet {
            device.orientation = Double(orientation)
            _captationArea.zRotation = deg2rad(self.horizontalFOV / -2 + orientation + 90)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    /// The horizontal field of view of the device, in degrees
    var horizontalFOV: CGFloat = 70 {
        didSet {
            device.horizontalFOV = Double(horizontalFOV)
            _captationArea.path = captationArea()
            _captationArea.zRotation = deg2rad(self.horizontalFOV / -2 + orientation + 90)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    /// The minimum distance to be from the device to be``` able to be detected (in cm)
    var minimumCaptationDistance: CGFloat = 50 {
        didSet {
            device.minimumCaptationDistance = Double(minimumCaptationDistance)
            _captationArea.path = captationArea()
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    /// The maximum distance to be from the device to be able to be detected (in cm)
    var maximumCaptationDistance: CGFloat = 450 {
        didSet {
            device.maximumCaptationDistance = Double(maximumCaptationDistance)
            _captationArea.path = captationArea()
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    
    // //////////////////////////
    // MARK: - SKNode properties
    
    /// Reference to the parent node
    ///
    /// Reference is weak to prevent circular referencing
    weak var canvas: LayoutCanvas!
    
    /// The sprite node holding the device image
    internal var _deviceSprite: SKSpriteNode!
    
    /// The shape used to trigger clicks on the device image
    internal var _centerCircle: SKShapeNode!
    
    /// The shape representing the device captation area
    internal var _captationArea: SKShapeNode!
    
    /// The name tag for the device on the scene
    internal var _deviceLabel: SKLabelNode!
    
    /// Tell is the device is currently selected
    internal var isSelected: Bool = false
    
    
    // ////////////////////////////////
    // MARK: - Sidebar Properties view
    
    /// Reference to the device parameters view when it is available
    internal lazy var _parametersController: PBLayoutCanvasDevicePropertiesController = {
        let storyboard = NSStoryboard(name: "Layout", bundle: nil)
        var controller = storyboard.instantiateController(withIdentifier: "deviceParametersController") as! PBLayoutCanvasDevicePropertiesController
        controller.device = self
        
        return controller
    }()
}


// /////////////////////
// MARK: - LayoutElement
extension LayoutCanvasDevice: LayoutCanvasElement {
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
extension LayoutCanvasDevice {
    /// Initialize a Device node
    ///
    /// - Parameters:
    ///   - canvas: The canvas on which the node should be inserted
    ///   - device: The device the node will represent
    convenience init(onCanvas canvas: LayoutCanvas, forDevice device: Device) {
        self.init()
        
        self.canvas = canvas
        
        // Set the represented device
        self.device = device
        
        // copy the values from the device to ourselves
        self.name = device.name
        self.horizontalFOV = CGFloat(device.horizontalFOV)
        self.minimumCaptationDistance = CGFloat(device.minimumCaptationDistance)
        self.maximumCaptationDistance = CGFloat(device.maximumCaptationDistance)
        self.position = CGPoint(device.position)
        self.orientation = CGFloat(device.orientation)
        self.height = CGFloat(device.height)
    
        // Set up the node
        isUserInteractionEnabled = false
        
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
        _captationArea.zRotation = deg2rad(self.horizontalFOV / -2 + orientation + 90)
        
        // Give them their idle style
        setIdleAppearance()
        
        // Insert them in the tree
        self.addChild(_centerCircle)
        self.addChild(_captationArea)
        self.addChild(_deviceSprite)
        self.addChild(_deviceLabel)
        
        // And insert ourselves
        canvas.frontLayer.addChild(self)
    }
    
    /// Duplicate the current node, and insert it in the layout and the scene
    internal func duplicate() {
        let newDevice = Device(from: device)
        
        canvas.layout.devices.append(newDevice)
        canvas.createNodeForExistingDevice(newDevice)
    }
}

extension LayoutCanvasDevice {
    func update() {}

    func deleteActions() {
        canvas.remove(device: self)

        removeAllChildren()
        removeFromParent()
    }
}


// ///////////////////
// MARK: - User events
extension LayoutCanvasDevice {
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
        self.position.x += (event.deltaX / canvas.root.xScale)
        self.position.y -= (event.deltaY / canvas.root.yScale)
        
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
        guard isSelected else {
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

// /////////////////////
// MARK: - SKNode utils
extension LayoutCanvasDevice {
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
     
        if _captationArea.path!.contains(clickLocationCaptationArea) ||
           _centerCircle.contains(clickLocationCenterArea) {
            return true
        }
        
        return false
    }
}
