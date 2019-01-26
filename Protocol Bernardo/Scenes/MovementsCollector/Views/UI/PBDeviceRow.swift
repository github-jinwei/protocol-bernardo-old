//
//  PBDeviceRow.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class PBDeviceRow: NSView {

    weak var topController: MovementsCollectorViewController!
    var serial:String!
    
    @IBOutlet weak var outletBox: NSBox!
    @IBOutlet weak var deviceNameField: NSTextField!
    @IBOutlet weak var serialField: NSTextField!
    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var quickLookButton: NSButton!
    
    var deviceDetailsPopover: PBDeviceDetailsPopover!
    
    @IBAction func toggleState(_ sender: AnyObject) {
        App.dae.toggleDeviceStatus(withSerial: serial)
    }
    
    @IBAction func openQuickLook(_ sender: AnyObject) {
        guard deviceDetailsPopover == nil else {
            deviceDetailsPopover.close();
            deviceDetailsPopover = nil;
            return;
        }
        
        deviceDetailsPopover = NSView.make(fromNib: "PBDeviceRow", owner: nil)!
        deviceDetailsPopover.show(
            relativeTo: quickLookButton.bounds,
            of: quickLookButton,
            preferredEdge: .maxX)
        
        deviceDetailsPopover.controller.refRow = self;
    }
    
    func setValues(withDevice device: DeviceStatus) {
        deviceNameField.stringValue = device.name
        serialField.stringValue = device.serial
        statusField.stringValue = getStateLabel(device.state)
        
        switch device.state.rawValue {
        case 1: // Connecting
            actionButton.isEnabled = true;
            actionButton.title = "Connect"
        case 2: // Connecting
            actionButton.isEnabled = false;
        case 3: // Ready
            actionButton.isEnabled = true;
            actionButton.title = "Activate"
        case 4: // Active
            actionButton.isEnabled = true;
            actionButton.title = "Pause"
        case 5: // Closing
            actionButton.isEnabled = false;
        default: // Errored
            actionButton.isEnabled = false;
            actionButton.title = "Errored"
        }
        
        deviceDetailsPopover?.controller.setValues(withDevice: device)
    }
    
    /// Gets the label for the device state
    ///
    /// - Parameter state: State of the device
    /// - Returns: Label for the state
    func getStateLabel(_ state: DeviceState) -> String {
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
