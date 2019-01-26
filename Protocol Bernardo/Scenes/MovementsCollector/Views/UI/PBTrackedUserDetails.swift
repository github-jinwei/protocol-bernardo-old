//
//  PBTrackedUserDetails.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-26.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBTrackedUserDetails: NSView {
    
    @IBOutlet weak var userIDField: NSTextField!
    @IBOutlet weak var trackingStatusField: NSTextField!
    @IBOutlet weak var userPosXField: NSTextField!
    @IBOutlet weak var userPosYField: NSTextField!
    @IBOutlet weak var userPosZField: NSTextField!
    
    func setValues(forUser user: User) {
        userIDField.stringValue = "User #\(user.userID)"
        trackingStatusField.stringValue = getLabel(forState: user.state)
    
        guard user.state == USER_TRACKED else {
            userPosXField.floatValue = 0.0
            userPosYField.floatValue = 0.0
            userPosZField.floatValue = 0.0
            return
        }
        
        userPosXField.floatValue = user.skeleton.torso.position.x
        userPosYField.floatValue = user.skeleton.torso.position.y
        userPosZField.floatValue = user.skeleton.torso.position.z
    }
    
    func getLabel(forState state: UserState) -> String {
        switch state {
        case USER_TRACKED: return "Tracking"
        case USER_CALIBRATING: return "Calibrating"
        case USER_MISSING: return "Missing"
        default: return "ERROR"
        }
    }
}
