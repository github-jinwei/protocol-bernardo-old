//
//  Core.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// The application structure Core
class Core {
    /// The Welcome Scene
    fileprivate var welcomeWindow: WelcomeWindow!

    /// The Devices Window
    fileprivate var devicesWindow: DevicesWindow!

    /// Used by the SceneSelectorController to register itself
    ///
    /// - Parameter controller: The WelcomeWindow
    func registerWelcomeWindow(_ controller: WelcomeWindow) {
        welcomeWindow = controller
    }

    /// Display the welcome window
    func showWelcomeWindow() {
        welcomeWindow?.view.window!.windowController?.showWindow(nil)
    }

    /// Used by the DevicesWindow to register itself in the core
    ///
    /// - Parameter controller: The DevicesWindow
    func registerDevicesWindow(_ controller: DevicesWindow) {
        devicesWindow = controller
    }

    /// Display the devices window
    func showDevicesWindow() {
        if devicesWindow == nil {
            let window = NSStoryboard(name: "DevicesWindow", bundle: nil).instantiateController(withIdentifier: "DevicesWindow")
            (window as? NSWindowController)?.showWindow(nil)
        }

        devicesWindow?.view.window!.windowController?.showWindow(nil)
    }
}
