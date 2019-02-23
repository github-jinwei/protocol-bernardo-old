//
//  LayoutWindowDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

protocol LayoutWindowDelegate: AnyObject {
    /// Tells the receiver that the user changed the interface mode
    ///
    /// - Parameters:
    ///   - _: The emitting window controller
    ///   - interfaceModeHasChanged: The selected interface mode
    func toolbar(_: LayoutWindowController, interfaceModeHasChanged: LayoutInterfaceMode)

    /// Tells the receiver that the user selected a calibration profile
    ///
    /// - Parameters:
    ///   - _: The emitting window controller
    ///   - calibrationProfileChanged: The selected calibration profile
    func toolbar(_: LayoutWindowController, calibrationProfileChanged: LayoutCalibrationProfile?)

    /// Tells the receiver the user wants to create a new device
    ///
    /// - Parameter _: The emitting window controller
    func createNewDevice(_: LayoutWindowController)

    /// Tells the receiver the user wants to create a new line
    ///
    /// - Parameter _: The emitting window controller
    func createNewLine(_: LayoutWindowController)

    /// Tells the receiver the user wants to clear the deltas for the current device
    ///
    /// - Parameter _: The emitting window controller
    func clearDeviceDeltas(_: LayoutWindowController)

    /// Tells the receiver the user wants to update the deltas for the current device
    ///
    /// - Parameter _: The emitting window controller
    func updateDeviceDeltas(_: LayoutWindowController)
}
