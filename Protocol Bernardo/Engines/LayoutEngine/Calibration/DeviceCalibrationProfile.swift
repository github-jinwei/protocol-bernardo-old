//
//  CalibratedDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class DeviceCalibrationProfile: Codable {
    var layoutDeviceUUID: String! {
        didSet { document?.markAsEdited() }
    }
    
    var physicalDeviceSerial: String? {
        didSet { document?.markAsEdited() }
    }
    
    var isReference: Bool! = false {
        didSet { document?.markAsEdited() }
    }
    
    var referenceDeviceUUID: String? {
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
    
    weak var document: LayoutDocument?
    
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

extension DeviceCalibrationProfile {
    var calibratedPosition: Point {
        // Get the layout device, or do nothing
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            return positionDelta
        }
        
        return layoutDevice.position + positionDelta;
    }
    
    var calibratedHeight: Double {
        // Get the layout device, or do nothing
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            return heightDelta
        }
        
        return layoutDevice.height + heightDelta
    }
    
    var calibratedOrientation: Double {
        // Get the layout device, or do nothing
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            return orientationDelta
        }
        
        return layoutDevice.orientation + orientationDelta
    }
}



extension DeviceCalibrationProfile {
    func globalCoordinates(forPosition position: Position) -> Position {
        // Create a new, empty position
        var globalPos = Position()
        
        // 2D position are unaffected
        globalPos.x2D = position.x2D
        globalPos.y2D = position.y2D
        
        // X and Z coordinates takes into account the angle of the tracking device
        globalPos.x = (position.x * cos(deg2rad(Float(-calibratedOrientation))) - position.z * sin(deg2rad(Float(-calibratedOrientation)))) - Float(calibratedPosition.x) * 10.0
        globalPos.z = (position.x * sin(deg2rad(Float(-calibratedOrientation))) + position.z * cos(deg2rad(Float(-calibratedOrientation)))) + Float(calibratedPosition.y) * 10.0
        
        // Y coordinate (Height) is not affected by the angle of capture
        globalPos.y = position.y + Float(calibratedHeight) * 10.0
        
        return globalPos
    }
}
