//
//  MovementsCollectorViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class MovementsCollectorViewController: NSViewController {
    
    weak var movementsCollector: MovementsCollector?
    @IBOutlet weak var devicesList: NSStackView!
    
    var _isAcquiring = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @IBAction func refreshDevicesList(_ sender: Any) {
        movementsCollector?.refreshDevicesList();
    }
    
    /// Called to pass a new status to the interface
    ///
    /// - Parameter status: The DAE status
    func statusUpdate(_ status: DAEStatus) {
        if(status.deviceCount != devicesList.views.count) {
            reloadDevicesList(withStatus: status)
            return
        }
        
        devicesList.views.forEach { view in
            let deviceView = view as! PBDeviceRow
            let serial = deviceView.serial!
            let device = status.devices[serial]!
            
            // Update in the values
            setViewValues(deviceView: deviceView, device: device)
        }
    }
    
    /// Regenerate all the device views
    ///
    /// - Parameter status: The new status to generate from
    func reloadDevicesList(withStatus status: DAEStatus) {
        // Remove previously added view
        devicesList.views.forEach { $0.removeFromSuperview() }
        
        status.devices.forEach { serial, device in
            let deviceView: PBDeviceRow = NSView.make(fromNib: "PBDeviceRow", owner: nil)
            
            // Values that will not change
            deviceView.serial = serial
            deviceView.outletBox.title = "Device #\(devicesList.views.count + 1)"
            
            // Insert the view in the stack
            devicesList.addView(deviceView, in: .top)
            
            // Fill in the values
            setViewValues(deviceView: deviceView, device: device)
        }
    }
    
    func setViewValues(deviceView: PBDeviceRow, device: DeviceStatus) {
        deviceView.deviceNameField.stringValue = device.name
        deviceView.serialField.stringValue = device.serial
        deviceView.statusField.stringValue = stateLabel(device.state)
        
        switch device.state.rawValue {
        case 1: // Connecting
            deviceView.actionButton.isEnabled = true;
            deviceView.actionButton.title = "Connect"
        case 2: // Connecting
            deviceView.actionButton.isEnabled = false;
        case 3: // Ready
            deviceView.actionButton.isEnabled = true;
            deviceView.actionButton.title = "Activate"
        case 4: // Active
            deviceView.actionButton.isEnabled = true;
            deviceView.actionButton.title = "Pause"
        case 5: // Closing
            deviceView.actionButton.isEnabled = false;
        default: // Errored
            deviceView.actionButton.isEnabled = false;
            deviceView.actionButton.title = "Errored"
        }
    }
    
    /// Gets the label for the device state
    ///
    /// - Parameter state: State of the device
    /// - Returns: Label for the state
    func stateLabel(_ state: DeviceState) -> String {
        switch state.rawValue {
        case 1: return "Idle"
        case 2: return "Connecting"
        case 3: return "Ready"
        case 4: return "Active"
        case 5: return "Closing"
        default: return "Errored"
        }
    }
}
