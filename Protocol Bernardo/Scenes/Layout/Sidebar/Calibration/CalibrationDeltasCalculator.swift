//
//  CalibrationDeltasCalculator.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-10.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

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
    fileprivate struct positionCollection {
        var device: Position? = nil
        var reference: Position? = nil
    }

    /// Positions of the primary user on both devices
    fileprivate var primaryPositions = positionCollection()

    /// Positions of the secondary user on both devices
    fileprivate var secondaryPositions = positionCollection()
}

extension CalibrationDeltasCalculator {
    /// Set the positions of the primary user on both devices. The positions must be
    /// on the global coordinate system
    ///
    /// - Parameters:
    ///   - devicePrimaryUser: Position on the device to calibrate
    ///   - referencePrimaryUser: Position on the reference device
    func set(devicePrimaryUser: Position, referencePrimaryUser: Position) {
        primaryPositions.device = devicePrimaryUser
        primaryPositions.reference = referencePrimaryUser
    }

    /// Set the positions of the secondary user on both devices. The positions must be
    /// on the global coordinate system
    ///
    /// - Parameters:
    ///   - devicePrimaryUser: Position on the device to calibrate
    ///   - referencePrimaryUser: Position on the reference device
    func set(deviceSecondaryUser: Position, referenceSecondaryUser: Position) {
        secondaryPositions.device = deviceSecondaryUser
        secondaryPositions.reference = referenceSecondaryUser
    }
    
    /// Reset the calculator, removing all stored positions
    func reset() {
        // Erase all positions
        primaryPositions = positionCollection()
        secondaryPositions = positionCollection()
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

        deltas.orientation = deviceVector.angle(with: referenceVector)

        deltas.xPosition = (primaryUserDeltas.xPosition + secondaryUserDeltas.xPosition) / 2
        deltas.yPosition = (primaryUserDeltas.yPosition + secondaryUserDeltas.yPosition) / 2
        
        deltas.height = (primaryUserDeltas.height + secondaryUserDeltas.height) / 2
        
        return deltas
    }

    /// Get the position and height deltas for the given position collection
    ///
    /// - Parameter positions: _
    /// - Returns: The deltas
    fileprivate func getDeltas(usingPositions positions: positionCollection) -> CalibrationDeltas {
        var deltas = CalibrationDeltas()

        deltas.xPosition = positions.device!.x - positions.reference!.x
        deltas.yPosition = positions.device!.z - positions.reference!.z

        deltas.height = positions.device!.y - positions.reference!.y

        return deltas
    }
}
