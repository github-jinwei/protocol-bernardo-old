//
//  PBDeviceRow.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBDeviceRow: NSView {

    /// Reference to the upper view
    weak var topController: DevicesSceneViewController!
    
    /// The serial of this device
    var serial:String!
    
    @IBOutlet weak var outletBox: NSBox!
    @IBOutlet weak var deviceNameField: NSTextField!
    @IBOutlet weak var serialField: NSTextField!
    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var quickLookButton: NSButton!
    
    /// The details popover
    var deviceDetailsPopover: PBDeviceDetailsPopover!
    
    /// Tell the DAE to change the device status
    ///
    /// - Parameter sender: _
    @IBAction func toggleState(_ sender: AnyObject) {
        App.dae.toggleDeviceStatus(withSerial: serial)
    }
    
    /// Open the popover view. If the popover is already open, this will close it
    ///
    /// - Parameter sender: _
    @IBAction func openQuickLook(_ sender: AnyObject) {
        // Make sure the popover isn't already open
        guard deviceDetailsPopover == nil else {
            // Close the popover properly
            deviceDetailsPopover.performClose(nil);
            deviceDetailsPopover = nil;
            return;
        }
        
        // Create the popover
        deviceDetailsPopover = NSNib.make(fromNib: "PBDeviceRow", owner: nil)!
        deviceDetailsPopover.show(
            relativeTo: quickLookButton.bounds,
            of: quickLookButton,
            preferredEdge: .maxX)
        
        deviceDetailsPopover.controller.refRow = self;
    }
    
    /// Update the values for the device using the given one
    ///
    /// - Parameter device: The device status
    func update(deviceValues device: DeviceStatus) {
        // Make sure the given device is really for us
        guard serial == device.serial else {
            return
        }
        
        // Update the values
        deviceNameField.stringValue = device.name
        serialField.stringValue = device.serial
        statusField.stringValue = device.stateLabel
        
        // Update the button value and state based on the device's state
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
        
        // Tell the popover to update its values if it exists
        deviceDetailsPopover?.controller.update(deviceValues: device)
    }
}
