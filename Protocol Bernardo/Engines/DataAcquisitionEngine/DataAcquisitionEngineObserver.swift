//
//  DataAcquisitionEngineObserver.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-07.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// The Data Acquisition Engine Observer should be used
/// to be able to receive events from the DAE
protocol DataAcquisitionEngineObserver: AnyObject {
    /// Called when the main state of the DAE changes
    ///
    /// - Parameters:
    ///   - dae: The current DAE
    ///   - newState: The new state of the DAE
    func dae(_ dae: DataAcquisitionEngine, devicesStatusUpdated devices: ConnectedDevices)
}
