//
//  PBTrackedUserDetails.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-26.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBTrackedUserDetailsExcerpt: NSView {
    
    @IBOutlet weak var userIDField: NSTextField!
    @IBOutlet weak var trackingStatusField: NSTextField!
    @IBOutlet weak var userPosXField: NSTextField!
    @IBOutlet weak var userPosYField: NSTextField!
    @IBOutlet weak var userPosZField: NSTextField!
    
    /// Update the user values
    ///
    /// - Parameter user:
    func update(userValues user: PhysicalUser) {
        userIDField.stringValue = "User #\(user.userID)"
        trackingStatusField.stringValue = getLabel(forState: user.state)
    
        guard user.state == USER_TRACKED else {
            userPosXField.intValue = 0
            userPosYField.intValue = 0
            userPosZField.intValue = 0
            return
        }
        
        userPosXField.intValue = Int32(user.centerOfMass.x)
        userPosYField.intValue = Int32(user.centerOfMass.y)
        userPosZField.intValue = Int32(user.centerOfMass.z)
    }
    
    /// Gets the label matching the user state
    ///
    /// - Parameter state: A user state
    /// - Returns: The corresponding label
    func getLabel(forState state: UserState) -> String {
        switch state {
        case USER_TRACKED: return "Tracking"
        case USER_CALIBRATING: return "Calibrating"
        case USER_MISSING: return "Missing"
        default: return "ERROR"
        }
    }
}
