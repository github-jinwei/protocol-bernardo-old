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
    
    var userDetailsViews = [Int16: PBTrackedUserDetailsExcerpt]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        popover.delegate = self
    }
    
    /// Update the view valus using the given PhysicalDevice
    ///
    /// - Parameter device: the device status
    func update(deviceValues device: PhysicalDevice) {
        // Update the view values
        deviceNameField.stringValue = device.name
        serialField.stringValue = device.serial
        deviceStateField.stringValue = device.state.label
        usersCountField.intValue = Int32(Int(device.users.count))
        
        update(users: device.users)
    }
    
    /// Update the users views
    ///
    /// - Parameter users: list of tracked
    internal func update(users: [PhysicalUser]) {
        // Update tracked users views values
        var receivedIDs = [Int16]()
        
        // for each tracked user
        users.forEach { user in
            receivedIDs.append(user.userID)
            
            guard let userView = userDetailsViews[user.userID] else {
                // This is a new user, let's give it a view
                let userView: PBTrackedUserDetailsExcerpt = NSNib.make(fromNib: "PBDeviceRow", owner: nil)
                userDetailsViews[user.userID] = userView
                userView.update(userValues: user)
                usersDetailsStackView.addView(userView, in: .trailing)
                return
            }
            
            userView.update(userValues: user)
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

// MARK: - NSPopoverDelegate
extension PBDeviceDetails: NSPopoverDelegate {
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
    
    func detachableWindow(for popover: NSPopover) -> NSWindow? {
        return nil
    }
}
