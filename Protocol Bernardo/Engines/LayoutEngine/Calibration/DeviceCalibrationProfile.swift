//
//  CalibratedDevice.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A device calibration profile contains the needed informations to correct
/// the position of the device with its physical counterparts
///
/// A calibration profile creates a link between a physical acquisition device and
/// a device placed on the loaded layout. The delta stored in the profile represents the
/// difference there is between the position specified for the device on the layout,
/// and the position of the device in the real world. The goal of the person creating
/// the installation, is to keep these deltas as close to zero as possible.
///
/// A calibration profile also provides method to transform a position on the device
/// referential to a position on the global coordinate system.
class DeviceCalibrationProfile: Codable {
    /// The UUID of the layout device this profile is linked to
    var layoutDeviceUUID: String! {
        didSet {
            document?.markAsEdited()
        }
    }

    /// The serial of the physical device this profile represent
    var physicalDeviceSerial: Serial? {
        didSet {
            document?.markAsEdited()
        }
    }

    /// Tells if this device should be treated as perfectly placed, and its deltas
    /// should be ignored
    var isReference: Bool! = false {
        didSet {
            document?.markAsEdited()
        }
    }
    
    /// The UUID of the layout device this device is calibrated against
    var referenceDeviceUUID: String? {
        didSet {
            document?.markAsEdited()
        }
    }

    /// The positionning differences between the layout device and
    /// the physical device
    var deltas: CalibrationDeltas = CalibrationDeltas() {
        didSet {
            document?.markAsEdited()
        }
    }
    
    /// Tell if the device is considered as calibrated. The delta values should be
    /// ignored if this value is not true.
    var isCalibrated: Bool! = false {
        didSet {
            document?.markAsEdited()
        }
    }
    
    /// Reference to the layout document, used to get the calibrated position for the device
    weak var document: LayoutDocument?

    /// Keys to encode when converting the profile to and from JSON
    private enum CodingKeys: String, CodingKey {
        case layoutDeviceUUID
        case physicalDeviceSerial
        case isReference
        case referenceDeviceUUID
        case deltas
        case isCalibrated
    }
}



// //////////////////////////////
// MARK: - Calibrated properties
extension DeviceCalibrationProfile {
    /// The device's calibrated position
    var calibratedPosition: Point {
        let positionDelta = Point(deltas.xPosition, deltas.yPosition)

        // Get the layout device, or do nothing
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            return positionDelta
        }
        
        return layoutDevice.position + positionDelta
    }

    /// The device's calibrated height
    var calibratedHeight: Double {
        // Get the layout device, or do nothing
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            return Double(deltas.height)
        }
        
        return layoutDevice.height + Double(deltas.height)
    }

    /// THe device's calibrated orientation
    var calibratedOrientation: Double {
        // Get the layout device, or do nothing
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            return Double(deltas.orientation ?? 0.0)
        }
        
        return layoutDevice.orientation + Double((deltas.orientation ?? 0.0))
    }
}


// ///////////////////////////////
// MARK: - Position transformation
extension DeviceCalibrationProfile {

    /// Transform the given position from the device referential to the global
    /// corrdinate system taking into account the deltas of the profile
    ///
    /// - Parameter position: The position to transform
    /// - Returns: The position in the global coordinate system
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

    /// Transform the given position from the device referential to the global
    /// corrdinate system ignoring the calibrated layout
    ///
    /// - Parameter position: The position to transform
    /// - Returns: The position in the global coordinate system
    func uncalibratedGlobalCoordinates(forPosition position: Position) -> Position {
        // Make sure we have an associated layout device
        guard let layoutDevice = document?.layout.device(withUUID: layoutDeviceUUID) else {
            print("No associated layout device")
            return position
        }

        // Create a new, empty position
        var globalPos = Position()

        // 2D position are unaffected
        globalPos.x2D = position.x2D
        globalPos.y2D = position.y2D

        // X and Z coordinates takes into account the angle of the tracking device
        globalPos.x = (position.x * cos(deg2rad(Float(-layoutDevice.orientation))) - position.z * sin(deg2rad(Float(-layoutDevice.orientation)))) - Float(layoutDevice.position.x) * 10.0
        globalPos.z = (position.x * sin(deg2rad(Float(-layoutDevice.orientation))) + position.z * cos(deg2rad(Float(-layoutDevice.orientation)))) + Float(layoutDevice.position.y) * 10.0

        // Y coordinate (Height) is not affected by the angle of capture
        globalPos.y = position.y + Float(layoutDevice.height) * 10.0

        return globalPos
    }
}
