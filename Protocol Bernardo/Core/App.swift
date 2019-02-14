//
//  App.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

struct App {
    /// The application core, handling the scenes
    static let core = Core()

    /// The Data Acquisition Engine
    static let dae = DataAcquisitionEngine()

    /// The Layout Engine is used to open and close layout documents
    static let layoutEngine = LayoutEngine()

    /// The Users Engine is used to store and access tracked users
    static let usersEngine = UsersEngine()

    static let documentsController = NSDocumentController()
}
