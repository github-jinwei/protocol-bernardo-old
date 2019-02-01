//
//  PBDevicePropertiesLine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-31.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBDevicePropertiesController: NSViewController {
    
    var device: LayoutElementDevice?
    
    @IBOutlet weak var nameField: NSTextField!
    
    @IBOutlet weak var fovField: NSTextField!
    @IBOutlet weak var fovStepper: NSStepper!
    
    @IBOutlet weak var minDistanceField: NSTextField!
    @IBOutlet weak var minDistanceStepper: NSStepper!
    
    @IBOutlet weak var maxDistanceField: NSTextField!
    @IBOutlet weak var maxDistanceStepper: NSStepper!
    
    @IBOutlet weak var xPositionField: NSTextField!
    @IBOutlet weak var xPositionStepper: NSStepper!
    
    @IBOutlet weak var yPositionField: NSTextField!
    @IBOutlet weak var yPositionStepper: NSStepper!
    
    @IBOutlet weak var orientationField: NSTextField!
    @IBOutlet weak var orientationStepper: NSStepper!
    
    @IBOutlet weak var heightField: NSTextField!
    @IBOutlet weak var heightStepper: NSStepper!
    
    
    // ///////////////
    // MARK: - Actions
    
    @IBAction func nameModified(_ sender: NSControl) {
        device?.name = sender.stringValue
    }
    
    @IBAction func fovModified(_ sender: NSControl) {
        device?.horizontalFOV = CGFloat(fovStepper.doubleValue)
    }
    
    @IBAction func minDistanceModified(_ sender: NSControl) {
        device?.minimumCaptationDistance = CGFloat(minDistanceStepper.doubleValue)
    }
    
    @IBAction func maxDistanceModified(_ sender: NSControl) {
        device?.maximumCaptationDistance = CGFloat(maxDistanceStepper.doubleValue)
    }
    
    @IBAction func xPositionModified(_ sender: NSControl) {
        device?.position.x = CGFloat(xPositionStepper.doubleValue)
    }
    
    @IBAction func yPositionModified(_ sender: NSControl) {
        device?.position.y = CGFloat(yPositionStepper.doubleValue)
    }
    
    @IBAction func orientationModified(_ sender: NSControl) {
        device?.orientation = CGFloat(orientationStepper.doubleValue)
    }
    
    @IBAction func heightModified(_ sender: NSControl) {
        device?.height = CGFloat(heightStepper.doubleValue)
    }
    
    
    // //////////////////////////
    // MARK: - Setters
    
    func set(name: String) {
        nameField?.stringValue = name
    }
    
    func set(fov: CGFloat) {
        fovField?.doubleValue = Double(fov)
        fovStepper?.doubleValue = Double(fov)
    }
    
    func set(minDistance: CGFloat) {
        minDistanceField?.doubleValue = Double(minDistance)
        minDistanceStepper?.doubleValue = Double(minDistance)
    }
    
    func set(maxDistance: CGFloat) {
        maxDistanceField?.doubleValue = Double(maxDistance)
        maxDistanceStepper?.doubleValue = Double(maxDistance)
    }
    
    func set(position: CGPoint) {
        xPositionField?.doubleValue = Double(position.x)
        xPositionStepper?.doubleValue = Double(position.x)
        
        yPositionField?.doubleValue = Double(position.y)
        yPositionStepper?.doubleValue = Double(position.y)
    }
    
    func set(orientation: CGFloat) {
        orientationField?.doubleValue = Double(orientation)
        orientationStepper?.doubleValue = Double(orientation)
    }
    
    func set(height: CGFloat) {
        heightField?.doubleValue = Double(height)
        heightStepper?.doubleValue = Double(height)
    }
    
    
    
    // ////////////
    // MARK: - Init
    
    override func viewDidAppear() {
        
        guard let device = device else { return }
        
        set(name: device.name ?? "")
        set(fov: device.horizontalFOV)
        set(minDistance: device.minimumCaptationDistance)
        set(maxDistance: device.maximumCaptationDistance)
        set(position: device.position)
        set(orientation: device.orientation)
        set(height: device.height)
    }
}
