//
//  PhysicalDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension DAEDeviceStatus {
    /// The device's serial
    var serial: Serial {
        get {
            var temp = _serial
            return withUnsafePointer(to: &temp) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: _serial)) {
                    String(cString: $0)
                }
            }
        }
    }

    /// The device's name
    var name: String {
        get {
            var temp = _name
            return withUnsafePointer(to: &temp) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: _name)) {
                    String(cString: $0)
                }
            }
        }
    }
    
    // List all the users in a Swift friendly format
    var users: [PhysicalUser] {
        get {
            var users = [PhysicalUser]()
            var pointer = _users

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
}
