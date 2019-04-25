//
//  User.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import Accelerate

/// A User represent a real life user as tracked by one or more devices.
class User {
    /// Unique ID for this user
    private(set) var uuid = UUID().uuidString

    /// The time this user has been created
    private(set) var trackingStartTime = Date()

    /// The calibration profile this user will use to do coordinate calculations
    weak var calibrationProfile: LayoutCalibrationProfile?
    
    /// The list serials of devices tracking this user
    /// [device serial: userID for this device]
    var devices: [Serial: Int16] = [:]
    
    /// The live tracked physic of the user, each Physical user
    /// corresponds to a version of the user as seen by a device.
    /// [device serial: physical user]
    var trackedPhysics: [Serial: PhysicalUser] = [:]

    /// History of all the averaged, calibrated physics of this user.
    ///
    /// The latest physic in the array represent the current physic of the user,
    /// and are the one represented by the `position` and `skeleton` properties.
    var physicsHistory: [PhysicalUser] = []
}

// MARK: - Accessing user physics
extension User {
    /// Give the first physic in the physics history of this user.
    ///
    /// This value is NOT the first tracked physic of the user if the number of physics
    /// updates for this user is greater than the history size specified by the `UsersEngine.delegate`
    var firstPhysic: PhysicalUser {
        return physicsHistory.first!
    }

    /// The latest physic tracked for this user. If the user is acrtively tracked, this
    /// represent its current position
    var latestPhysic: PhysicalUser {
        return physicsHistory.last!
    }

    /// Average, calibrated position of the user (its torso) in the global coordinates
    /// system as inferred from all the tracked physics available.
    /// The 2D coordinates of this position will always be 0
    var position: float3 {
        return physicsHistory.last!.skeleton.torso.position
    }

    /// Average, calibrated skeleton of the user (positions and angle) in the global coordinates
    /// system as inferred from all the tracked physics available.
    /// The 2D coordinates are irrelevents here
    var skeleton: Skeleton {
        return physicsHistory.last!.skeleton
    }
}

// MARK: - Calculations
extension User {
    /// Calculate the merged position and skeleton on the global coordinate system,
    /// and add it to the history of physics assumed by the user.
    func calculatePosition(historySize: UInt) {
        physicsHistory.append(PhysicalUser(userID: 0,
                                           frame: (physicsHistory.last?.frame ?? 0) + 1,
                                           state: USER_TRACKED,
                                           skeleton: calculateMergedSkeleton(),
                                           centerOfMass: calculateMergedPosition()))
//
//        physicsHistory.append(PhysicalUser(userID: 0,
//                                           frame: (physicsHistory.last?.frame ?? 0) + 1,
//                                           state: USER_TRACKED,
//                                           skeleton: trackedPhysics.first!.value.skeleton,
//                                           centerOfMass: trackedPhysics.first!.value.centerOfMass))

        if physicsHistory.count > historySize + 1 {
            physicsHistory.removeFirst(physicsHistory.count - (Int(historySize) + 1))
        }
    }

    /// Calculate the averaged, merged, position of the user on the global coordinate system
    ///
    /// - Returns: The user's position
    private func calculateMergedPosition() -> float3 {
		var userPos = float3(repeating: 0)

        // Make sure we have a calibration profile, and that we are actively tracking the user
        guard trackedPhysics.count > 0, let profile = calibrationProfile else {
            return userPos
        }

        // Do the median position from all the tracking devices
        for (serial, physic) in trackedPhysics {
            // Get the user CoM in the global coordinaters system
            let gPos = profile.device(forSerial: serial)!.globalCoordinates(forPosition: physic.skeleton.torso.position)

            userPos.x += gPos.x
            userPos.y += gPos.y
            userPos.z += gPos.z
        }

        return userPos / Float(trackedPhysics.count)
    }

    /// Calculate the averaged, merged, skeleton of the user on the global coordinates
    /// system
    ///
    /// - Returns: The user's skeleton
    private func calculateMergedSkeleton() -> Skeleton {
        let availablePhysics: Float = Float(trackedPhysics.count)

        let length = Skeleton.propertiesCount
        let vdspLength = vDSP_Length(Skeleton.propertiesCount)

        var props = [Float](repeating: 0, count: length)
        var confs = [Float](repeating: 0, count: length)

        var tmp = [Float](repeating: 0, count: length)
        var tmp2 = [Float](repeating: 0, count: length)

        for (serial, physic) in trackedPhysics {
            var pProps = physic.skeleton.allProperties(usingProfile: calibrationProfile!.device(forSerial: serial)!)
            var pConfs = physic.skeleton.allConfidences

            // Mult props by their confidence
            vDSP_vmul(&pProps, 1, &pConfs, 1, &tmp, 1, vdspLength)

            // Add to the props accumulator
            vDSP_vadd(&props, 1, &tmp, 1, &tmp2, 1, vdspLength)
            props = tmp2

            // Add the confs to the confs accumulator
            vDSP_vadd(&confs, 1, &pConfs, 1, &tmp, 1, vdspLength)
            confs = tmp
        }

        // Do the medium of the acc props using the acc confs
        vDSP_vdiv(&confs, 1, &props, 1, &tmp, 1, vdspLength)
        props = tmp

        // Do the medium of confidences
        var confDividers: [Float] = [Float](repeating: availablePhysics, count: length)
        vDSP_vdiv(&confDividers, 1, &confs, 1, &tmp, 1, vdspLength)
        confs = tmp

        return Skeleton(properties: props, confidences: confs)
    }
}
