//
//  AppDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Assing the main menu to our app
        (aNotification.object as! NSApplication).mainMenu = NSNib.make(fromNib: "MainMenu", owner: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openSceneSelector(_ sender: Any) {
        App.core.openSceneSelector()
    }
}

