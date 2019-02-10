//
//  DeviceStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

struct DeviceStatus {
    var name: String
    
    var serial: String
    
    var state: DeviceState
    
    var users: [PhysicalUser]
    
    init(from status: DAEDeviceStatus) {
        self.name = status.name
        self.serial = status.serial
        self.state = status.state
        self.users = status.users
    }
}

extension DeviceStatus {
    /// English label for the current device state
    var stateLabel: String {
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
