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
    /// Reference to the movements collector scene
    weak var movementsCollector: MovementsCollector?
    @IBOutlet weak var devicesList: NSStackView!
    
    /// Asks for a refresh of the available devices list
    ///
    /// - Parameter sender: _
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
            deviceView.update(deviceValues: device)
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
            deviceView.topController = self
            deviceView.serial = serial
            deviceView.outletBox.title = "Device #\(devicesList.views.count + 1)"
            
            // Fill in the values
            deviceView.update(deviceValues: device)
            
            // Insert the view in the stack
            devicesList.addView(deviceView, in: .top)            
        }
    }
}

