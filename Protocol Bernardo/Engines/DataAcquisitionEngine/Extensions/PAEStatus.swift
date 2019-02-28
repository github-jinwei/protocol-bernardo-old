//
//  DAEStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Represent the current state of the C++ DAE
///
/// You should not use this structure directly as it is converted to `ConnectedDevices` upon
/// receiving.
extension PAEStatus {
    /// List of all the devices in a Swift friendly format
    func copyAndDeallocate() -> [Serial: PhysicalDevice] {
        // The map
        var devicesMap = [Serial: PhysicalDevice]()

        // Pointer used for parsing
        var pointer = connectedDevices
        
        // Loop on each device
        for i in 0..<deviceCount {
            let daeDeviceStatus = pointer!.pointee
            
            // Insert in the map
            devicesMap[daeDeviceStatus.serial] = PhysicalDevice(from: daeDeviceStatus)
            
            // Free it
            daeDeviceStatus.trackedUsers.deallocate()
            
            // Check if we can advance
            if i + 1 < deviceCount {
                pointer = pointer?.successor()
            }
        }
        
        // Free the array
        connectedDevices.deallocate()
        
        return devicesMap
    }
}
