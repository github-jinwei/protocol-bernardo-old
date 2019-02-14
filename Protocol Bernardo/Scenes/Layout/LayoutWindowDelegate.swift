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
    ///   - _: The emitter window controller
    ///   - interfaceModeHasChanged: The selected interface mode
    func toolbar(_: LayoutWindowController, interfaceModeHasChanged: LayoutInterfaceMode)

    /// Tells the receiver that the user selected a calibration profile
    ///
    /// - Parameters:
    ///   - _: The emitter window controller
    ///   - calibrationProfileChanged: The selected calibration profile
    func toolbar(_: LayoutWindowController, calibrationProfileChanged: LayoutCalibrationProfile?)
}
