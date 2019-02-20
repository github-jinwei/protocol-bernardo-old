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

    @IBAction func createLayout(_: NSMenuItem) {
        App.layoutEngine.newLayout()
    }

    /// Prompt the user to open a layout document
    @IBAction func openLayout(_: Any) {
        App.layoutEngine.openLayout()
    }


    /// Show the welcome screen
    ///
    /// - Parameter sender: _
    @IBAction func openWelcomeWindow(_: Any?) {
        App.core.showWelcomeWindow()
    }

    /// Open the devices scene
    ///
    /// - Parameter sender: _
    @IBAction func openDevicesWindow(_: Any?) {
        App.core.showDevicesWindow()
    }
}
