//
//  DataAcquisitionEngineDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol DataAcquisitionEngineDelegate: AnyObject {
    /// Called when the main state of the DAE changes
    ///
    /// - Parameters:
    ///   - dae: The current DAE
    ///   - newState: The new state of the DAE
    func dae(_ dae: DataAcquisitionEngine, statusUpdated status: DAEStatus)
}
