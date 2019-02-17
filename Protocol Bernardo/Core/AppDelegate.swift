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

    fileprivate var fileToOpen: URL!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Assing the main menu to our app
//        guard let application = aNotification.object as? NSApplication else { return }

//        application.mainMenu = NSNib.make(fromNib: "MainMenu", owner: nil)

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
