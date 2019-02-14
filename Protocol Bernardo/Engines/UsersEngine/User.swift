//
//  User.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A User represent a real life user as tracked by one or more devices.
class User {
    /// Unique ID for this user
    var uuid = UUID().uuidString
    
    /// The list serials of devices tracking this user
    /// [device serial: userID for this device]
    var devices: [Serial: Int16] = [:]
    
    /// The tracked physic of the user, each Physical user
    /// corresponds to a version of the user as seen by a device.
    /// [device serial: physical user]
    var trackedPhysics: [Serial: PhysicalUser] = [:]
    
    /// The calibration profile this user will use to do coordinate calculations
    weak var calibrationProfile: LayoutCalibrationProfile?
}

extension User {
    /// Position of the user (its center of mass) in the global coordinates system
    /// as inferred from all the tracked physics available
    /// The 2D coordinates of this position will always be 0
    var calibratedPosition: Position {
        var userCoM = Position()
        
        // Make sure we have a calibration profile, and that we are actively tracking the user
        guard trackedPhysics.count > 0, let profile = calibrationProfile else {
            return userCoM
        }
        
        // Do the median position from all the tracking devices
        trackedPhysics.forEach { serial, physic in
            // Get the user CoM in the global coordinaters system
            let gPos = profile.device(forSerial: serial)!.globalCoordinates(forPosition: physic.centerOfMass)
            
            userCoM.x += gPos.x
            userCoM.y += gPos.y
            userCoM.z += gPos.z
        }
        
        return userCoM / Float(trackedPhysics.count)
    }
    
    /// Skeleton of the user (if available) in the global coordinates system with
    /// its position inferred from all the tracked physics available
    var calibratedSkeleton: Skeleton? { return Skeleton() }
}
