//
//  CalibratedDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class CalibratedDevice: Codable {
    var layoutDeviceUUID: String!
    
    var physicalDeviceSerial: String!
    
    var isReference: Bool! = false
    
    var positionDelta = Point(x: 0.0, y: 0.0)
    
    var orientationDelta: Double = 0.0
    
    var heightDelta: Double = 0.0
    
    var isCalibrated: Bool! = false
}
