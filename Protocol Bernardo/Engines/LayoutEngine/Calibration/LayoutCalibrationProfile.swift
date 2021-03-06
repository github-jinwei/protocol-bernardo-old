//
//  LayoutCalibration.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A layout calibration profile is a collection of device calibration profile
/// for the current layout.
class LayoutCalibrationProfile: Codable {
    /// Name of the calibration profile
    var name: String

    /// All the calibrated devices, identified by their uuid in the layout
    var calibratedDevices: [DeviceCalibrationProfile] = []

    /// The layout document this calibration profile belongs to
    weak var document: LayoutDocument? {
        didSet {
            // Pass the reference to the layout document to each calibrated device
            for device in calibratedDevices {
                device.document = document
            }
        }
    }
    
    /// Keys to encode when converting the profile to and from JSON
    private enum CodingKeys: String, CodingKey {
        case name
        case calibratedDevices
    }
    
    init(name: String) {
        self.name = name
    }
}

// MARK: - Managing devices profiles
extension LayoutCalibrationProfile {
    /// Insert a new device in the profile, with the given layout device uuid
    ///
    /// - Parameter uuid: An existing layout device
    /// - Returns: The newly created device profile
    func addDevice(withUUID uuid: String) -> DeviceCalibrationProfile {
        let device = DeviceCalibrationProfile()
        device.layoutDeviceUUID = uuid
        device.document = self.document
        calibratedDevices.append(device)
        
        return device
    }
}


// MARK: - Accessing devices profiles
extension LayoutCalibrationProfile {
    /// Gives the corresponding profile for the given device serial
    ///
    /// - Parameter serial: A device serial
    /// - Returns: The corresponding calibration profile, if any
    func device(forSerial serial: Serial) -> DeviceCalibrationProfile? {
        return calibratedDevices.first { $0.physicalDeviceSerial == serial }
    }
    
    /// Gives the corresponding profile for the given layout device uuid
    ///
    /// - Parameter serial: A layout device uuid
    /// - Returns: The corresponding calibration profile, if any
    func device(forUUID uuid: String?) -> DeviceCalibrationProfile? {
        if uuid == nil {
            return nil
        }

        return calibratedDevices.first { $0.layoutDeviceUUID == uuid }
    }
}
