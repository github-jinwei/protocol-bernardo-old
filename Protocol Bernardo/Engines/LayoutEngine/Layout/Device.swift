//
//  Device.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Device: Codable {
    var name: String = "Device"
    
    var horizontalFOV: CGFloat = 70.0
    
    var minimumCaptationDistance: CGFloat = 50.0
    
    var maximumCaptationDistance: CGFloat = 450.0
    
    var position = CGPoint(x: 0, y: 0)
    
    var orientation: CGFloat = 0.0
    
    var height: CGFloat = 60.0
}

extension Device {
    convenience init(from device: Device) {
        self.init()
        
        print(device.position)
        
        self.name = device.name
        self.horizontalFOV = device.horizontalFOV
        self.minimumCaptationDistance = device.minimumCaptationDistance
        self.maximumCaptationDistance = device.maximumCaptationDistance
        self.position = device.position
        self.orientation = device.orientation
        self.height = device.height
    }
}
