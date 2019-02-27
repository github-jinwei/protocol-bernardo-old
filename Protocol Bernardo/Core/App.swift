//
//  App.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// The app struct is made to be used globaly to access various entity
/// needed by different parts of the application
struct App {
    /// The application core, handling the scenes
    static let core = Core()

    /// The Data Acquisition Engine
    static let dae = DataAcquisitionEngine()

    /// The Layout Engine is used to open and close layout documents
    static let layoutEngine = LayoutEngine()

    /// The Users Engine is used to store and access tracked users
    static let usersEngine = UsersEngine()

    /// The document controller used by the various documents engines
    static let documentsController = NSDocumentController()

    /// The utility queue running concurrently for background tasks.
    ///
    /// The queue as a QoS set as userInitiated.
    static let utilityQueue = DispatchQueue(
        label: "studio.prisme.pb.utilityQueue",
        qos: DispatchQoS.userInitiated)
}
