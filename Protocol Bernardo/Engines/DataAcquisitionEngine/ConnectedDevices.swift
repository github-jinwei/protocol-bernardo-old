//
//  ConnectedDevices.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-12.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Container for all the connected devices.
///
/// You should no create this ourselves, use the one the DataAcquistionEngine
/// gives to its observers
class ConnectedDevices {
    /// List of all connected devices
    internal var _devices: [Serial: PhysicalDevice] = [:]

    /// All the connected devices
    var devices: [Serial: PhysicalDevice] {
        get {
            return _devices
        }
    }

    /// Tells the number of connected devices available
    var count: Int {
        get {
            return _devices.count
        }
    }

    /// Set the connected devices list.
    ///
    /// Should only be used by the DataAcquisitionEngine
    ///
    /// - Parameter devices: _
    func setDevices(_ devices: [Serial: PhysicalDevice]) {
        _devices = devices
    }

}


// MARK: - Access Methods
extension ConnectedDevices {

    /// Return the connected device with the matching serial
    ///
    /// Returns nil if there is no matching device
    ///
    /// - Parameter serial: A physical device serial
    /// - Returns: A physical device
    func with(serial: Serial?) -> PhysicalDevice? {
        if serial == nil {
            return nil
        }

        return _devices.first(where: { $0.key == serial })?.value
    }

}
