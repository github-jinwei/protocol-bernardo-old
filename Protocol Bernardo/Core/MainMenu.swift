//
//  MainMenu.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// Receptacle for all the custom interactions coming from the application menu
class MainMenu: NSMenu {

    /// Create a new layout and open it
    ///
    /// - Parameter _: _
    @IBAction func createLayout(_: NSMenuItem) {
        App.layoutEngine.newLayout()
    }

    /// Prompt the user to open a layout document
    @IBAction func openLayout(_: Any) {
        App.layoutEngine.openLayout()
    }

	@IBAction func showHomeWindow(_: Any) {
		App.core.showHomeWindow()
	}
}
