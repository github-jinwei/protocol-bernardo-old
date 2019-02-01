//
//  DevicesLayoutEditorScene.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class DevicesLayoutEditorScene: NSWindowController {
    // ////////////////////////////////////
    // MARK: Inherited elements from Scene
    var sceneIndex: Int!
    static var sceneName = "Devices Layout Editor"
    static var sceneDescription = "Create and edit devices layout to map real-world installations."
    
    // /////////////////
    // MARK: - Properties
    
    internal var _editor: LayoutEditor {
        return (contentViewController as! LayoutEditorSplitViewController).editor
    }
    
    
    // ////////////////
    // Scene Lifecycle
    
    override func windowDidLoad() {
        (contentViewController as! LayoutEditorSplitViewController).window = self
    }
    
    // ///////////////////////
    // MARK: - Toolbar Actions
    
    @IBAction func addDevice(_ sender: NSToolbarItem) {
        _editor.addDevice()
    }
}

// MARK: - NSWindowDelegate
extension DevicesLayoutEditorScene: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        endScene()
    }
}

extension DevicesLayoutEditorScene: Scene {
    static func make() -> Scene {
        let storyboard = NSStoryboard(name: "LayoutEditor", bundle: nil)
        let window = storyboard.instantiateInitialController() as! DevicesLayoutEditorScene
        window.showWindow(nil)
        
        return window
    }
}
