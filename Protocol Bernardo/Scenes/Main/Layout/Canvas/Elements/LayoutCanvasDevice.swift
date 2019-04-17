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
    
    /// The device delegate
    weak var delegate: LayoutCanvasElementDelegate!
    
    // ////////////////////////////////
    // MARK: - Device properties remap
    
    override var name: String? {
        didSet {
            device.name = name!
            deviceLabel?.text = name

            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }

    override var position: CGPoint {
        didSet {
            device.position = double2(Double(position.x), Double(position.y))

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
            captationAreaNode.zRotation = deg2rad(self.horizontalFOV / -2 + orientation + 90)
            
            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }

    /// The horizontal field of view of the device, in degrees
    var horizontalFOV: CGFloat = 70 {
        didSet {
            device.horizontalFOV = Double(horizontalFOV)
            captationAreaNode.path = captationArea()
            captationAreaNode.zRotation = deg2rad(self.horizontalFOV / -2 + orientation + 90)

            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }

    /// The minimum distance to be from the device to be``` able to be detected (in cm)
    var minimumCaptationDistance: CGFloat = 50 {
        didSet {
            device.minimumCaptationDistance = Double(minimumCaptationDistance)
            captationAreaNode.path = captationArea()

            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }

    /// The maximum distance to be from the device to be able to be detected (in cm)
    var maximumCaptationDistance: CGFloat = 450 {
        didSet {
            device.maximumCaptationDistance = Double(maximumCaptationDistance)
            captationAreaNode.path = captationArea()

            // Tell the delegate
            delegate?.elementDidChange(self)
        }
    }
    
    
    // //////////////////////////
    // MARK: - SKNode properties
    
    /// The sprite node holding the device image
    private var deviceSprite: SKSpriteNode!
    
    /// The shape used to trigger clicks on the device image
    private var centerCircle: SKShapeNode!
    
    /// The shape representing the device captation area
    private var captationAreaNode: SKShapeNode!
    
    /// The name tag for the device on the scene
    private var deviceLabel: SKLabelNode!

    /// The calibrated center circle of the device
    private var calibratedCenterCircle: SKShapeNode!
    
    /// Tell is the device is currently selected
    internal var isSelected: Bool = false {
        didSet {
            liveDeltas = nil
        }
    }

    /// Tell if the device is currently being calibrated
	public var isCalibrating: Bool {
		return liveDeltas != nil
	}

    /// Live deltas, used when the device is calibrating
    public var liveDeltas: CalibrationDeltas? {
        didSet {
            if liveDeltas != nil {
                // Update the calibrated center circle position
                calibratedCenterCircle.position.x = CGFloat(liveDeltas!.xPosition) / 10.0
                calibratedCenterCircle.position.y = CGFloat(liveDeltas!.yPosition) / 10.0

                showCalibratedPosition()
            }
        }
    }
    
    
    // ////////////////////////////////
    // MARK: - Sidebar Properties view
    
    /// Reference to the device parameters view when it is available
    private(set) lazy var parametersController: NSViewController = {
		let controller: LayoutDevicePropertiesViewController = NSNib.make(fromNib: "Layout", owner: nil)
        controller.device = self
        
        return controller
    }()
}

// /////////////////////
// MARK: - LayoutElement
extension LayoutCanvasDevice: LayoutCanvasElement {
    /// Update the position values for the device on the parameters view
    func updatePositionOnParameters() {
        (parametersController as? LayoutDevicePropertiesViewController)?.set(position: position)
    }
}

// ///////////////////
// MARK: - Initializer
extension LayoutCanvasDevice {
    /// Initialize a Device node
    ///
    /// - Parameters:
    ///   - layoutView: The layoutView on which the node should be inserted
    ///   - device: The device the node will represent
    convenience init(onCanvas canvas: LayoutViewController, forDevice device: Device) {
        self.init()
        
        // Set the represented device
        self.device = device
        
        // copy the values from the device to ourselves
        self.name = device.name
        self.horizontalFOV = CGFloat(device.horizontalFOV)
        self.minimumCaptationDistance = CGFloat(device.minimumCaptationDistance)
        self.maximumCaptationDistance = CGFloat(device.maximumCaptationDistance)
        self.position = CGPoint(x: CGFloat(device.position.x), y: CGFloat(device.position.y))
        self.orientation = CGFloat(device.orientation)
        self.height = CGFloat(device.height)
    
        // Set up the node
        isUserInteractionEnabled = false
        
        // Build the device sprite node
        deviceSprite = SKSpriteNode(imageNamed: "Device")
        deviceSprite.position.y += 3
        deviceSprite.setScale(0.15)
        deviceSprite.colorBlendFactor = 1.0
        
        deviceLabel = SKLabelNode(text: self.name)
        deviceLabel.horizontalAlignmentMode = .center
        deviceLabel.verticalAlignmentMode = .center
        deviceLabel.position.y -= 12
        deviceLabel.fontSize = 11
        deviceLabel.fontName = NSFont.systemFont(ofSize: 11, weight: .bold).fontName
        
        centerCircle = SKShapeNode(circleOfRadius: 25)

        calibratedCenterCircle = SKShapeNode(circleOfRadius: 25)
        
        // Build the captation area node
        captationAreaNode = SKShapeNode(path: captationArea())
        captationAreaNode.zRotation = deg2rad(self.horizontalFOV / -2 + orientation + 90)
        
        // Give them their idle style
        setIdleAppearance()
        
        // Insert them in the tree
        self.addChild(centerCircle)
        self.addChild(calibratedCenterCircle)
        self.addChild(captationAreaNode)
        self.addChild(deviceSprite)
        self.addChild(deviceLabel)
        
        // And insert ourselves
        canvas.frontLayer.addChild(self)
    }
    
    /// Tell the delegate to duplicate this layout
    internal func duplicate() {
        delegate?.duplicateDeviceElement(self)
    }
}

extension LayoutCanvasDevice {
    func deleteActions() {
        removeAllChildren()
        removeFromParent()
    }
}

// ////////////////////
// MARK: - Frame update
extension LayoutCanvasDevice {
    /// Called by the layout layoutView on each render frame
    func update() {
        // Do nothing if the device is calibrating
        if isCalibrating {
            return
        }
        
        // Get the calibrated position of the device
        guard let deviceProfile = delegate?.deviceProfile(forDevice: device) else {
            return
        }

        // Update the calibrated center circle position
        calibratedCenterCircle.position.x = CGFloat(deviceProfile.deltas.xPosition) / 10.0
        calibratedCenterCircle.position.y = CGFloat(deviceProfile.deltas.yPosition) / 10.0

        if isSelected {
            showCalibratedPosition()
        }
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

        let scale = delegate?.canvasRootNode().xScale ?? 1.0
        
        // Adjust the node position accordingly
        self.position.x += (event.deltaX / scale)
        self.position.y -= (event.deltaY / scale)
        
        // Update the represented device and the parameters view
        updatePositionOnParameters()
        
        // Tell our delegate we got updated
        delegate?.elementDidChange(self)
    }
}

// //////////////////
// MARK: - Appearance
extension LayoutCanvasDevice {
    func set(appearance: LayoutCanvasElementAppearance) {
        switch appearance {
        case .idle:
            setIdleAppearance()
        case .selected:
            setSelectedAppearance()
        }
    }

    /// Set the device appearance to reflect its idle state
    private func setIdleAppearance() {
        deviceSprite.color = NSColor(calibratedWhite: 0, alpha: 0.9)
        deviceLabel.fontColor = NSColor(calibratedWhite: 0, alpha: 0.8)
        
        centerCircle.alpha = 0.0
        
        captationAreaNode.fillColor = NSColor(calibratedWhite: 0, alpha: 0.5)
        captationAreaNode.strokeColor = NSColor(calibratedWhite: 0, alpha: 0.8)

        hideCalibratedPosition()
    }

    /// Set the device appearance to reflect its selected state
    private func setSelectedAppearance() {
        centerCircle.alpha = 1.0
        centerCircle.fillColor = NSColor(highlightColor, alpha: 0.5)
        centerCircle.strokeColor = NSColor(highlightColor, alpha: 0.8)
        
        captationAreaNode.fillColor = NSColor(highlightColor, alpha: 0.5)
        captationAreaNode.strokeColor = NSColor(highlightColor, alpha: 0.8)
    }

    /// Show the calibrated center position
    private func showCalibratedPosition() {
        calibratedCenterCircle.alpha = 1.0
        calibratedCenterCircle.fillColor = NSColor(NSColor.systemGreen, alpha: 0.4)
        calibratedCenterCircle.strokeColor = NSColor(NSColor.systemGreen, alpha: 0.6)
    }

    /// Hide the calibrated center position
    private func hideCalibratedPosition() {
        calibratedCenterCircle.alpha = 0.0
    }
}

// /////////////////////
// MARK: - SKNode utils
extension LayoutCanvasDevice {
    /// Gives the CGPath corresponding to the device captation area
    ///
    /// - Returns: A CGPath representing an arc
    private func captationArea() -> CGMutablePath {
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
        let clickLocationCaptationArea = event.location(in: captationAreaNode)
        let clickLocationCenterArea = event.location(in: centerCircle)
     
        if captationAreaNode.path!.contains(clickLocationCaptationArea) ||
           centerCircle.contains(clickLocationCenterArea) {
            return true
        }
        
        return false
    }
}
