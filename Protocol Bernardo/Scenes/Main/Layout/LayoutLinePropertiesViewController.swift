//
//  PBDevicePropertiesLine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-31.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutLinePropertiesViewController: NSViewController, LayoutElementPropertiesViewController {
    
    weak var line: LayoutCanvasLine?
    
    @IBOutlet weak var sizeField: NSTextField!
    @IBOutlet weak var sizeStepper: NSStepper!
    
    @IBOutlet weak var weightField: NSTextField!
    @IBOutlet weak var weightStepper: NSStepper!

	@IBOutlet weak var xPositionField: NSTextField!
	@IBOutlet weak var xPositionStepper: NSStepper!

	@IBOutlet weak var yPositionField: NSTextField!
	@IBOutlet weak var yPositionStepper: NSStepper!

	@IBOutlet weak var orientationField: NSTextField!
	@IBOutlet weak var orientationStepper: NSStepper!
    
    // ///////////////
    // MARK: - Actions
    
    @IBAction func sizeModified(_: NSControl) {
        line?.size = CGFloat(sizeStepper.doubleValue)
    }
    
    @IBAction func weightModified(_: NSControl) {
        line?.weight = CGFloat(weightStepper.doubleValue)
    }
    
    @IBAction func xPositionModified(_: NSControl) {
        line?.position.x = CGFloat(xPositionStepper.doubleValue)
    }
    
    @IBAction func yPositionModified(_: NSControl) {
        line?.position.y = CGFloat(yPositionStepper.doubleValue)
    }
    
    @IBAction func orientationModified(_: NSControl) {
        line?.orientation = CGFloat(orientationStepper.doubleValue)
    }
    
    // //////////////////////////
    // MARK: - Setters
    
    func set(size: CGFloat) {
        sizeStepper?.doubleValue = Double(size)
        sizeField?.doubleValue = Double(size)
    }
    
    func set(weight: CGFloat) {
        weightField?.doubleValue = Double(weight)
        weightStepper?.doubleValue = Double(weight)
    }

    // ////////////
    // MARK: - Init
    
    override func viewDidAppear() {
        
        guard let line = line else { return }
        
        set(size: line.size)
        set(weight: line.weight)
        set(position: line.position)
        set(orientation: line.orientation)
    }
}
