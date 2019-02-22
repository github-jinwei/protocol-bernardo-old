//
//  AppDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

/// Application main delegate
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        App.core.showWelcomeWindow()
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)

        App.layoutEngine.openLayout(at: url)

        return true
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
    }
}


extension AppDelegate {
    @IBAction func newLayout(_ sender: Any) {
        App.layoutEngine.newLayout()
    }

    @IBAction func openLayout(_ sender: Any) {
        App.layoutEngine.openLayout()
    }

    @IBAction func showDevicesWindow(_ sender: Any) {
        App.core.showDevicesWindow()
    }
}
