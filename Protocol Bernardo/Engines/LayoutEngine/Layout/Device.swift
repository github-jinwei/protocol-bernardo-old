//
//  Device.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Device: Codable {
    var uuid: String! = UUID().uuidString
    
    var name: String = "Device"
    
    var horizontalFOV: Double = 70.0
    
    var minimumCaptationDistance: Double = 50.0
    
    var maximumCaptationDistance: Double = 450.0
    
    var position = Point(x: 0, y: 0)
    
    var orientation: Double = 0.0
    
    var height: Double = 60.0
}

extension Device {
    convenience init(from device: Device) {
        self.init()
        
        print(device.position)
        
        self.uuid = device.uuid
        self.name = device.name
        self.horizontalFOV = device.horizontalFOV
        self.minimumCaptationDistance = device.minimumCaptationDistance
        self.maximumCaptationDistance = device.maximumCaptationDistance
        self.position = device.position
        self.orientation = device.orientation
        self.height = device.height
    }
}
