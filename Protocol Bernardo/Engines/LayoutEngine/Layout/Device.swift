//
//  Device.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Logical representation of a physical device.
///
/// Some values are directly used to represent the device on the layout
/// interface while some other are not represented but still take part
/// in the user tracking process.
class Device: Codable {
    /// Unique ID for this device
    var uuid: String! = UUID().uuidString
    
    /// The device's name
    var name: String = "Device"
    
    /// The device horizontal FOV
    var horizontalFOV: Double = 70.0
    
    /// The device's minimum captation distance
    var minimumCaptationDistance: Double = 50.0
    
    /// The device's maximum captation distance
    var maximumCaptationDistance: Double = 450.0
    
    /// The device's position (in cm)
    var position = Point(x: 0, y: 0)
    
    /// The device's orientation (in degrees)
    var orientation: Double = 0.0
    
    /// The device's height
    var height: Double = 60.0
    
    /// Convenient init used to duplicate a device
    ///
    /// - Parameter device: An existing device to use as source
    convenience init(from device: Device) {
        self.init()
        
        self.uuid = UUID().uuidString
        self.name = device.name
        self.horizontalFOV = device.horizontalFOV
        self.minimumCaptationDistance = device.minimumCaptationDistance
        self.maximumCaptationDistance = device.maximumCaptationDistance
        self.position = device.position
        self.orientation = device.orientation
        self.height = device.height
        
        print(device.uuid, self.uuid)
    }
}
