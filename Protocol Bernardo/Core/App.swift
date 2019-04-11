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
    static let pae = PositionAcquisitionEngine()


    /// The Layout Engine is used to open and close layout documents
    static let layoutEngine = LayoutEngine()

	/// Layout engine shortcut
	static var le: LayoutEngine { return layoutEngine }


    /// The Users Engine is used to store and access tracked users
    static let usersEngine = UsersEngine()

	/// Users engine shortcut
	static var ue: UsersEngine { return usersEngine }
}
