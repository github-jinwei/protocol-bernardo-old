//
//  DevicesLayout.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Layout is a representation of a real-world installation.
///
/// A Layout is used to enable user tracking accross multiple devices. It is composed
/// of two kind of elements. The devices and decorations elements (lines currently)
class Layout: Codable {
    /// All the devices composing the layout
    var devices = [Device]()
    
    /// All the lines composing the layout
    var decorations = [Line]()

    /// The calibration profile selected when closing the profile
    /// Used to restart 
    var profile: String?

	/// Ip of the relay server for the PAE
	var serverIP: String?

	/// Port of the relay server for the PAE
	var serverPort: String?
}


// /////////////////////////////
// MARK: - Actions on the layout
extension Layout {
    /// Create a new device on the layout and returns it
    ///
    /// - Returns: The newly created device
    func createDevice() -> Device {
        let device = Device()
		device.name += " #" + String(devices.count + 1)
        devices.append(device)
        
        return device
    }
    
    /// Create a new line on the layout and returns it
    ///
    /// - Returns: The newly created line
    func createLine() -> Line {
        let line = Line()
        decorations.append(line)
        
        return line
    }
    
    /// Remove the given device from the layout
    ///
    /// - Parameter device: The device to remove
    func remove(device: Device) {
        devices.removeAll {
            $0 === device
        }
    }
    
    /// Remove the given line from the layout
    ///
    /// - Parameter line: The line to remove
    func remove(line: Line) {
        decorations.removeAll {
            $0 === line
        }
    }
}

// MARK: - Accessing the layout content
extension Layout {
    /// Return the device on the layout with the corresponding UUID
    /// If no device matches the given UUID, returns nil
    ///
    /// - Parameter deviceUUID: A layout device UUID
    /// - Returns: The layout device
    func device(withUUID deviceUUID: String) -> Device? {
        let foundDevices = devices.filter { $0.uuid == deviceUUID }
        guard foundDevices.count == 1 else { return nil }
        return foundDevices[0]
    }
    
}
