//
//  PBSceneButton.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class PBSceneButton: NSView {
    /** The Type of the scene this view opens */
    var sceneType: Scene.Type!
    
    @IBOutlet var sceneNameField: NSTextField!
    @IBOutlet var sceneDescriptionField: NSTextField!
    
    /// Open the scene represented by this view
    ///
    /// - Parameter sender: _
    @IBAction func openScene(_ sender: NSButton) {
        App.core.makeScene(ofType: sceneType)
        
        self.window?.close()
    }
}
