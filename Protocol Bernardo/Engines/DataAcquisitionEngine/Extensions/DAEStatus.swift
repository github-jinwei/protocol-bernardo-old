//
//  DAEStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension DAEStatus {
    /// List of all the devices in a Swift friendly format
    func copyAndDeallocate() -> [String: PhysicalDevice] {
        // The map
        var devicesMap = [String: PhysicalDevice]()

        // Pointer used for parsing
        var pointer = _deviceStatus
        
        // Loop on each device
        for i in 0..<deviceCount {
            let daeDeviceStatus = pointer!.pointee
            
            // Insert in the map
            devicesMap[daeDeviceStatus.serial] = PhysicalDevice(from: daeDeviceStatus)
            
            // Free it
            daeDeviceStatus._users.deallocate()
            
            // Check if we can advance
            if i + 1 < deviceCount {
                pointer = pointer?.successor()
            }
        }
        
        // Free the array
        _deviceStatus.deallocate()
        
        return devicesMap
    }
}
