//
//  SceneSelectorController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

/// The `Scene Selector` is the first window that appears at the start of the app.
///
/// It displays a list of the scene the user can start. These scenes are defined
/// in the `availableScenes` array, and must conform the `Scene` protocol.
class WelcomeSceneViewController: NSViewController {
    
    @IBOutlet var visualEffectView: NSVisualEffectView!
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear() {
    }
    
    @IBAction func newLayout(_ sender: Any) {
        App.layoutEngine.newLayout()
    }
    
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
}

