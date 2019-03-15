//
//  PhysicalDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Represent a real-world physical device
struct PhysicalDevice {
    /// The name of the device's host
    var hostname: String

    /// The name of the device
    var name: String
    
    /// The device's serial number
    var serial: Serial
    
    /// The device's state
    var state: DeviceState
    
    /// All the physical users tracked by the device
    var users: [PhysicalUser]
    
    init(from status: PAEDeviceStatus) {
        self.hostname = status.hostname
        self.name = status.name
        self.serial = status.serial
        self.state = status.state
        self.users = status.users
    }
}

extension PhysicalDevice {
    /// Returns all the physical users actively tracked by this device
    var trackedUsers: [PhysicalUser] {
        return users.filter { $0.state == USER_TRACKED }
    }
}
