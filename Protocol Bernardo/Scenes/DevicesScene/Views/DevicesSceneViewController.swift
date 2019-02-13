//
//  DevicesSceneViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class DevicesSceneViewController: NSViewController {
    /// Reference to the movements collector scene
    weak var movementsCollector: DevicesScene?
    @IBOutlet weak var devicesList: NSStackView!
    
    /// Called to pass a new status to the interface
    ///
    /// - Parameter status: The DAE status
    func statusUpdate(_ devices: ConnectedDevices) {
        if(devices.count != devicesList.views.count) {
            reloadDevicesList(withDevices: devices)
            return
        }
        
        devicesList.views.forEach { view in
            let deviceView = view as! PBDeviceRow
            let serial = deviceView.serial!
            let device = devices.with(serial: serial)!
            
            // Update in the values
            deviceView.update(deviceValues: device)
        }
    }
    
    /// Regenerate all the device views
    ///
    /// - Parameter status: The new status to generate from
    func reloadDevicesList(withDevices connectedDevices: ConnectedDevices) {
        // Remove previously added view
        devicesList.views.forEach { $0.removeFromSuperview() }
        
        for (serial, device) in connectedDevices.devices {
            let deviceView: PBDeviceRow = NSNib.make(fromNib: "PBDeviceRow", owner: nil)
            
            // Values that will not change
            deviceView.topController = self
            deviceView.serial = serial
            deviceView.outletBox.title = "Device #\(devicesList.views.count + 1)"
            
            // Fill in the values
            deviceView.update(deviceValues: device)
            
            // Insert the view in the stack
            devicesList.addView(deviceView, in: .top)            
        }
        
        // Resize the window to match the devices list
        view.window?.setContentSize(view.fittingSize)
    }
}

