//
//  PAEDeviceStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A PAEDeviceStatus is used to carry the current status of an acquisition device,
/// including the users it is currently tracking.
///
/// The main purpose of this structure is to create a bridge between the C++ DAE
/// and Swift. This structure should not be used directly as it is converted to `AcquisitionDevice`
/// upon receiving.
extension PAEDeviceStatus {
    /// The device's serial
    var serial: Serial {
		return String.fromCString(deviceSerial)
    }

    /// The device's name
    var name: String {
		return String.fromCString(deviceName)
    }
    
    // List all the users in a Swift friendly format
    var users: [PhysicalUser] {
        var users = [PhysicalUser]()
        var pointer = trackedUsers

        for i in 0..<userCount {
            let user = pointer!.pointee

            users.append(user)

            if i + 1 < userCount {
                pointer = pointer?.successor()
            }
        }
        
        return users
    }
}
