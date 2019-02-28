//
//  PhysicalDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A DAEDeviceStatus is used to carry the current status of an acquisition device,
/// including the users it is currently tracking.
///
/// The main purpose of this structure is to create a bridge between the C++ DAE
/// and Swift. This structure should not be used directly as it is converted to `PhysicalDevice`
/// upon receiving.
extension DAEDeviceStatus {
    /// The device's host name
    var hostname: String {
        var temp = deviceHostname
        return withUnsafePointer(to: &temp) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: deviceHostname)) {
                String(cString: $0)
            }
        }
    }

    /// The device's serial
    var serial: Serial {
        var temp = deviceSerial
        return withUnsafePointer(to: &temp) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: deviceSerial)) {
                String(cString: $0)
            }
        }
    }

    /// The device's name
    var name: String {
        var temp = deviceName
        return withUnsafePointer(to: &temp) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: deviceName)) {
                String(cString: $0)
            }
        }
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
