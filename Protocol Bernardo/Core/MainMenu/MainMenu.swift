//
//  MainMenu.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class MainMenu: NSMenu {
    @IBAction func openWelcomeScene(_ sender: Any?) {
        NSApplication.shared.windows[0].windowController?.showWindow(nil)
    }
    
    @IBAction func openDevicesScene(_ sender: Any?) {
        App.core.makeScene(ofType: DevicesScene.self)
    }
}
