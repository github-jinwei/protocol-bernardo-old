//
//  CalibrationController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit
import simd

class CalibrationController {

    // //////////////////
    // MARK: - Properties

    weak var delegate: CalibrationControllerDelegate?

    weak var layout: Layout!

    private var deltasCalculator = CalibrationDeltasCalculator()

    // //////////////////////////////
    // MARK: - Calibration Properties

    /// Calibration profile used by the controller
    private var calibrationProfile: LayoutCalibrationProfile?

    /// Device Calibration Profile for the selected layout device
    private var deviceProfile: DeviceCalibrationProfile?

    /// The latest deltas available
    private var latestDeltas: CalibrationDeltas?


    // //////////////////////////////
    // MARK: - Lifecycle

    init() {
		App.pae.addObserver(self)
    }

    deinit {
        App.pae.removeObserver(self)
    }
}



// ///////////////////
// MARK: - Profile properties
extension CalibrationController {
    /// Set the controller calibration profile
    ///
    /// - Parameter profile: _
    func set(calibrationProfile profile: LayoutCalibrationProfile?) {
        calibrationProfile = profile
        deviceProfile = nil
    }

    /// UUID of the device being calibrated
    var deviceUUID: String? {
        get {
            return deviceProfile?.layoutDeviceUUID
        }
        set {
            guard let uuid = newValue else {
                deviceProfile = nil
                return
            }

            guard let calibrationProfile = self.calibrationProfile else { return }

            // Set the device calibration profile
            deviceProfile = calibrationProfile.device(forUUID: uuid) ??
                            calibrationProfile.addDevice(withUUID: uuid)

            delegate?.calibration(self, storedDeltasChanged: deviceProfile!.deltas)
        }
    }

    /// Serial of the physical device being calibrated
    var deviceSerial: Serial? {
        get {
            return deviceProfile?.physicalDeviceSerial
        }
        set {
            deviceProfile?.physicalDeviceSerial = newValue
        }
    }

    /// Tell if the device is a reference one
    var isReference: Bool? {
        get {
            return deviceProfile?.isReference
        }
        set {
            deviceProfile?.isReference = newValue ?? false
        }
    }

    /// UUID of the reference device
    var referenceUUID: String? {
        get {
            return deviceProfile?.referenceDeviceUUID
        }
        set {
            deviceProfile?.referenceDeviceUUID = newValue
        }
    }

    /// The calibration profile of the reference device
    private var referenceProfile: DeviceCalibrationProfile? {
        return calibrationProfile?.device(forUUID: referenceUUID)
    }

    /// Serial of the reference device
    private var referenceSerial: Serial? {
        return referenceProfile?.physicalDeviceSerial
    }

    /// Store the latest deltas inside the profile to be used during tracking
    func storeDeltas() {
        guard let deltas = latestDeltas else { return }

        deviceProfile?.deltas = deltas

        delegate?.calibration(self, storedDeltasChanged: deltas)
    }

    /// Reset the stored deltas to zero
    func clearDeltas() {
        guard let deviceProfile = self.deviceProfile else { return }

        deviceProfile.deltas = CalibrationDeltas()

        delegate?.calibration(self, storedDeltasChanged: deviceProfile.deltas)
    }
}



// /////////////
// MARK: - Lists
extension CalibrationController {
    /// List of layout devices that can be selected
    var layoutDevicesList: [String: Bool] {
        var list: [String: Bool] = [:]

        // Insert all the connected devices
        for device in layout.devices {
            list[device.name] = true
        }

        return list
    }

    /// List of availbale physical devices
    var physicalDevicesList: [String: Bool] {
        var list: [String: Bool] = [:]

        /// Insert the already present device serial
        if let deviceSerial = deviceProfile?.physicalDeviceSerial {
            list[deviceSerial] = false
        }

        // Insert all the connected devices
        for (serial, _) in App.pae.devices {
            list[serial] = true
        }

        return list
    }

    /// List of available reference devices
    var referenceDevicesList: [String: Bool] {
        var list: [String: Bool] = [:]

        // Insert all devices available for calibration
        for device in layout.devices {
            // If its the device to calibrate, skip it
            guard device.uuid != deviceUUID else { continue }

            // Get the device calibration profile
            let profile = calibrationProfile?.device(forUUID: device.uuid)

            // Tell if it is usable for referencing, and adjust its name if needed
            let isUsable = profile?.isCalibrated ?? false || profile?.isReference ?? false
            let deviceName = isUsable ? device.name : device.name + " (Not Calibrated)"

            // Insert it in the list
            list[deviceName] = isUsable
        }

        return list
    }
}



// /////////////////////////////////////
// MARK: - PositionAcquisitionEngineObserver
extension CalibrationController: PositionAcquisitionEngineObserver {
    func pae(_ pae: PositionAcquisitionEngine, statusUpdated connectedDevices: [AcquisitionMachine]) {
        // Propagate the values to the delegate
        delegate?.calibration(self, physicalDeviceStateChanged: physicalDeviceState)
        delegate?.calibration(self, referenceDeviceStateChanged: referenceDeviceState)

        // And calculate the deltas if possible
        calculateDeltas()
    }

    /// Give the latest state of the selected physical device
    ///
    /// - Parameter connectedDevices: Connected devices from the pae
    var physicalDeviceState: DeviceState {
        guard let deviceSerial = self.deviceSerial else { return DEVICE_UNKNOWN }

        guard let physicalDevice = App.pae.devices[deviceSerial] else { return DEVICE_UNKNOWN }

        return physicalDevice.state
    }

    /// Give the latest state of the selected reference device
    ///
    /// - Parameter connectedDevices: Connected devices from the pae
    var referenceDeviceState: DeviceState {
        guard let deviceSerial = self.referenceSerial else { return DEVICE_UNKNOWN }

        guard let physicalDevice = App.pae.devices[deviceSerial] else { return DEVICE_UNKNOWN }

        return physicalDevice.state
    }
}



// ///////////////////////////
// MARK: - Deltas Calculations
extension CalibrationController {
    private func calculateDeltas() {
        // Deltas can only be caclulated if the two devices are active
        guard physicalDeviceState == DEVICE_ACTIVE && referenceDeviceState == DEVICE_ACTIVE else {
            // Tell the delegate there is no calibration tracking
            delegate?.calibration(self, liveDeltasUpdated: nil)
            return
        }

        // Get the two devices.
        // Because the two devices states are active, we kow they exist
        let physicalDevice = App.pae.devices[deviceSerial!]!
        let referenceDevice = App.pae.devices[referenceSerial!]!

        // reset calculator
        deltasCalculator.reset()

        // Each device has to track at least one user
        guard physicalDevice.trackedUsers.count >= 1 &&
              referenceDevice.trackedUsers.count >= 1 else {
                // Tell the delegate there is no calibration tracking
                delegate?.calibration(self, liveDeltasUpdated: nil)
                return
        }

        // Get the two primary users positions
        let primaryDevicePos = uncalibratedGlobalPosition(
                                            ofUser: physicalDevice.trackedUsers[0],
                                            withProfile: deviceProfile!)
        let primaryReferencePos = uncalibratedGlobalPosition(
                                            ofUser: referenceDevice.trackedUsers[0],
                                            withProfile: referenceProfile!)

        // Add the positions to the calculator
        deltasCalculator.set(devicePrimaryUser: primaryDevicePos,
                              referencePrimaryUser: primaryReferencePos)

        // If the two devices have at least two users, use them too
        guard physicalDevice.trackedUsers.count >= 2 &&
              referenceDevice.trackedUsers.count >= 2 else {
                // There is only one user usable, get deltas and send them to the delegate
                latestDeltas = deltasCalculator.getDeltas()
                delegate?.calibration(self, liveDeltasUpdated: latestDeltas)
                return
        }

        // Get the secondary users positions
        let secondaryDevicePos = uncalibratedGlobalPosition(
            ofUser: physicalDevice.trackedUsers[1],
            withProfile: deviceProfile!)
        let secondaryReferencePos = uncalibratedGlobalPosition(
            ofUser: referenceDevice.trackedUsers[1],
            withProfile: referenceProfile!)

        // Add them to the calculator
        deltasCalculator.set(deviceSecondaryUser: secondaryDevicePos, referenceSecondaryUser: secondaryReferencePos)

        // Get and store the deltas
        latestDeltas = deltasCalculator.getDeltas()

        // Send them to the delegate
        delegate?.calibration(self, liveDeltasUpdated: latestDeltas)

    }

    /// Gives the uncalibrated global position of the center of mass of the given user
    /// using the provided calibration profile
    ///
    /// - Parameters:
    ///   - user: Physical user to work with
    ///   - profile: Calibration profile to use for the conversion
    /// - Returns: The user center of mass in the global coordinate system without any calibration adjustements
    private func uncalibratedGlobalPosition(ofUser user: PhysicalUser, withProfile profile: DeviceCalibrationProfile) -> float3 {
        let localPosition = user.skeleton.torso.position
        return profile.uncalibratedGlobalCoordinates(forPosition: localPosition)
    }
}
