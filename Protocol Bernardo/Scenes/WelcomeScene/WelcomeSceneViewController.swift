//
//  SceneSelectorController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

class WelcomeSceneViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.core.registerWelcomeScene(self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window!.isMovableByWindowBackground = true
    }
    
    // ////////////
    // MARK: Layout
    
    /// Open a new, empty layout
    ///
    /// - Parameter sender:
    @IBAction func newLayout(_ sender: Any) {
        App.layoutEngine.newLayout()
    }
    
    /// Asks the user to select an existing layout to open
    ///
    /// - Parameter sender:
    @IBAction func openLayout(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["pblayout"]
        openPanel.runModal()
        
        guard let fileURL = openPanel.url else { return }
        
        App.layoutEngine.openLayout(at: fileURL)
    }
    
    
    // /////////////
    // MARK: Display
    
    
    // /////////////
    // MARK: Syncing
}

