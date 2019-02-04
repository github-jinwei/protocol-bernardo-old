//
//  DevicesLayoutEditorScene.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEditorScene: NSWindowController {
    // ////////////////////////////////////
    // MARK: Inherited elements from Scene
    var sceneIndex: Int!
    static var sceneName = "Layout Editor"
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
        _editor.createDevice()
    }
}

// MARK: - NSWindowDelegate
extension LayoutEditorScene: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        endScene()
    }
}

extension LayoutEditorScene: Scene {
    static func make() -> Scene {
        let storyboard = NSStoryboard(name: "LayoutEditor", bundle: nil)
        let window = storyboard.instantiateInitialController() as! LayoutEditorScene
        window.showWindow(nil)
        
        return window
    }
}
