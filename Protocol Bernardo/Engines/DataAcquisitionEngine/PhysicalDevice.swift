//
//  PhysicalDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Represent a real-worldm physical device
struct PhysicalDevice {
    /// The name of the device
    var name: String
    
    /// The device's serial number
    var serial: Serial
    
    /// The device's state
    var state: DeviceState
    
    /// All the physical users tracked by the device
    var users: [PhysicalUser]
    
    init(from status: DAEDeviceStatus) {
        self.name = status.name
        self.serial = status.serial
        self.state = status.state
        self.users = status.users
    }
}

extension PhysicalDevice {
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
