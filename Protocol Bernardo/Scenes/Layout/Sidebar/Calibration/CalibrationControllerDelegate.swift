//
//  CalibrationControllerDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol CalibrationControllerDelegate: AnyObject {
    /// Tell the delegate the state of the connected physical device has changed
    ///
    /// - Parameters:
    ///   - controller: The emitting CalibrationController
    ///   - physicalDeviceStateChanged: The new state of the device
    func calibration(_ controller: CalibrationController, physicalDeviceStateChanged: DeviceState)

    /// Tell the delegate the state of the connected reference device has changed
    ///
    /// - Parameters:
    ///   - controller: The emitting CalibrationController
    ///   - referenceDeviceStateChanged: The new state of the device
    func calibration(_ controller: CalibrationController, referenceDeviceStateChanged: DeviceState)

    /// Tell the delegate the live deltas have changed. Given deltas can be nil,
    /// meaning there is no calibration tracking happening
    ///
    /// - Parameters:
    ///   - controller: The emitting CalibrationController
    ///   - liveDeltasUpdated: The latest live deltas
    func calibration(_ controller: CalibrationController, liveDeltasUpdated: CalibrationDeltas?)

    /// Tells the delegated the stored deltas have been updated
    ///
    /// - Parameters:
    ///   - controller: The emitting CalibrationController
    ///   - storedDeltasChanged: The current device stored deltas
    func calibration(_ controller: CalibrationController, storedDeltasChanged: CalibrationDeltas)
}
