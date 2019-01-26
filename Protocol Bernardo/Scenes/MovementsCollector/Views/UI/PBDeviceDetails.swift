//
//  PBDeviceDetails.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBDeviceDetails: NSViewController {
    
    weak var refRow: PBDeviceRow!
    
    @IBOutlet weak var popover: NSPopover!
    
    @IBOutlet weak var deviceNameField: NSTextField!
    @IBOutlet weak var serialField: NSTextField!
    @IBOutlet weak var deviceStateField: NSTextField!
    @IBOutlet weak var usersCountField: NSTextField!
    
    @IBOutlet weak var usersDetailsStackView: NSStackView!
    
    var userDetailsViews = [Int16: PBTrackedUserDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popover.delegate = self
    }
    
    func setValues(withDevice device: DeviceStatus) {
        // Update the view values
        deviceNameField.stringValue = device.name
        serialField.stringValue = device.serial
        deviceStateField.stringValue = refRow.getStateLabel(device.state)
        usersCountField.intValue = Int32(Int(device.userCount))
        
        // Update tracked users views values
        var receivedIDs = [Int16]()
        
        // for each tracked user
        device.users.forEach { user in
            receivedIDs.append(user.userID)
            
            guard let userView = userDetailsViews[user.userID] else {
                // This is a new user, let's give it a view
                let userView:PBTrackedUserDetails = NSView.make(fromNib: "PBDeviceRow", owner: nil)
                userDetailsViews[user.userID] = userView
                userView.setValues(forUser: user)
                usersDetailsStackView.addView(userView, in: .trailing)
                return
            }
            
            userView.setValues(forUser: user)
        }
        
        // Remove users
        userDetailsViews.forEach { userID, userView in
            if receivedIDs.contains(userID) {
                // User is not missing, do nothing.
                return
            }
            
            // User is missing, remove him from the array
            userDetailsViews.removeValue(forKey: userID)
            usersDetailsStackView.removeView(userView)
        }
    }
}

extension PBDeviceDetails: NSPopoverDelegate {
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
    
    func detachableWindow(for popover: NSPopover) -> NSWindow? {
        return nil
    }
}
