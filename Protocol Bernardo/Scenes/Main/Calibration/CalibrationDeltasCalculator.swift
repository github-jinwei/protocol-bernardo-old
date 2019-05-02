//
//  CalibrationDeltasCalculator.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-10.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

/// Calculate positioning deltas between two devices
///
/// The CalibrationDeltasCalculator uses provided position for one or two users
/// to calculate positioning difference between the two devices.
///
/// X, Y and Height deltas can be calculated with only one user. The orientation
/// deltas needs a second user to be calculated
class CalibrationDeltasCalculator {

    /// Inner structure to store a couple of position for the same user accross
    /// two devices
    private struct PositionCollection {
        var device: float3?
        var reference: float3?
    }

    /// Positions of the primary user on both devices
    private var primaryPositions = PositionCollection()

    /// Positions of the secondary user on both devices
    private var secondaryPositions = PositionCollection()
}

extension CalibrationDeltasCalculator {
    /// Set the positions of the primary user on both devices. The positions must be
    /// on the global coordinate system
    ///
    /// - Parameters:
    ///   - devicePrimaryUser: Position on the device to calibrate
    ///   - referencePrimaryUser: Position on the reference device
    func set(devicePrimaryUser: float3, referencePrimaryUser: float3) {
        primaryPositions.device = devicePrimaryUser
        primaryPositions.reference = referencePrimaryUser
    }

    /// Set the positions of the secondary user on both devices. The positions must be
    /// on the global coordinate system
    ///
    /// - Parameters:
    ///   - devicePrimaryUser: Position on the device to calibrate
    ///   - referencePrimaryUser: Position on the reference device
    func set(deviceSecondaryUser: float3, referenceSecondaryUser: float3) {
        secondaryPositions.device = deviceSecondaryUser
        secondaryPositions.reference = referenceSecondaryUser
    }
    
    /// Reset the calculator, removing all stored positions
    func reset() {
        // Erase all positions
        primaryPositions = PositionCollection()
        secondaryPositions = PositionCollection()
    }
}

extension CalibrationDeltasCalculator {
    /// Gives the calibration deltas using the stored positions. Gives nil if
    /// no positions are set
    ///
    /// - Returns: The calibration deltas
    public func getDeltas() -> CalibrationDeltas? {
        // Do we have a primary user ?
        guard primaryPositions.device != nil && primaryPositions.reference != nil else {
            return nil
        }

        // Calculate the primary user deltas
        let primaryUserDeltas = getDeltas(usingPositions: primaryPositions)

        // Do we have a secondary user ?
        guard secondaryPositions.device != nil && secondaryPositions.reference != nil else {
            // Only a primary user, return its deltas
            return primaryUserDeltas
        }

        // Calculate the secondary user deltas
        let secondaryUserDeltas = getDeltas(usingPositions: secondaryPositions)

        // Get the vectors for each device
        let deviceVector = primaryPositions.device! - secondaryPositions.device!
        let referenceVector = primaryPositions.reference! - secondaryPositions.reference!

        // Store the deltas
        var deltas = CalibrationDeltas()

        // Get the orientation delta between the device and the referenceVector
        deltas.orientation = atan2f(referenceVector.z, referenceVector.x) -
                            atan2f(deviceVector.z, deviceVector.x)

        deltas.xPosition = (primaryUserDeltas.xPosition + secondaryUserDeltas.xPosition) / 2
        deltas.yPosition = (primaryUserDeltas.yPosition + secondaryUserDeltas.yPosition) / 2
        
        deltas.height = (primaryUserDeltas.height + secondaryUserDeltas.height) / 2
        
        return deltas
    }

    /// Get the position and height deltas for the given position collection
    ///
    /// - Parameter positions: _
    /// - Returns: The deltas
    private func getDeltas(usingPositions positions: PositionCollection) -> CalibrationDeltas {
        var deltas = CalibrationDeltas()

        deltas.xPosition = positions.reference!.x - positions.device!.x
        deltas.yPosition = positions.reference!.z - positions.device!.z

        deltas.height = positions.reference!.y - positions.device!.y

        return deltas
    }
}
