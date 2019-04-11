//
//  PositionAcquisitionEngineObserver.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-07.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// The Data Acquisition Engine Observer should be used
/// to be able to receive events from the DAE
protocol PositionAcquisitionEngineObserver: AnyObject {
    /// Called when the main state of the DAE changes
    ///
    /// - Parameters:
    ///   - pae: The current DAE
    ///   - newState: The new state of the DAE
    func pae(_ pae: PositionAcquisitionEngine, statusUpdated machines: [AcquisitionMachine])
}
