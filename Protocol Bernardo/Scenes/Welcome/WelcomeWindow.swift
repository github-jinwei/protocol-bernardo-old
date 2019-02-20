//
//  SceneSelectorController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

class WelcomeWindow: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.core.registerWelcomeWindow(self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        // Stylize the window
        self.view.window!.isMovableByWindowBackground = true

        self.view.window!.titleVisibility = .hidden
        self.view.window!.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.view.window!.standardWindowButton(.zoomButton)?.isHidden = true
    }
    
    // ////////////
    // MARK: Layout
    
    /// Open a new, empty layout
    ///
    /// - Parameter sender:
    @IBAction func newLayout(_: Any) {
        App.layoutEngine.newLayout()
    }
    
    /// Asks the user to select an existing layout to open
    ///
    /// - Parameter sender:
    @IBAction func openLayout(_: Any) {
        App.layoutEngine.openLayout()
    }
    
    
    // /////////////
    // MARK: Display
    
    
    // /////////////
    // MARK: Syncing
}
