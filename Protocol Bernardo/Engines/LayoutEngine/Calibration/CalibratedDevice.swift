//
//  CalibratedDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class CalibratedDevice: Codable {
    var layoutDeviceUUID: String! {
        didSet { document?.markAsEdited() }
    }
    
    var physicalDeviceSerial: String! {
        didSet { document?.markAsEdited() }
    }
    
    var isReference: Bool! = false {
        didSet { document?.markAsEdited() }
    }
    
    var positionDelta = Point(x: 0.0, y: 0.0) {
        didSet { document?.markAsEdited() }
    }
    
    var orientationDelta: Double = 0.0 {
        didSet { document?.markAsEdited() }
    }
    
    var heightDelta: Double = 0.0 {
        didSet { document?.markAsEdited() }
    }
    
    var isCalibrated: Bool! = false {
        didSet { document?.markAsEdited() }
    }
    
    var document: LayoutDocument?
    
    private enum CodingKeys: String, CodingKey {
        case layoutDeviceUUID
        case physicalDeviceSerial
        case isReference
        case positionDelta
        case orientationDelta
        case heightDelta
        case isCalibrated
    }
}
