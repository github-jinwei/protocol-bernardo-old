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
    
    var sceneType: Scene.Type!
    
    @IBOutlet var sceneNameField: NSTextField!
    @IBOutlet var sceneDescriptionField: NSTextField!
    
    @IBAction func openScene(_ sender: NSButton) {
        App.core.makeScene(ofType: sceneType)
        
        self.window?.close()
    }
    
    /// The view borders width
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer?.borderWidth = borderWidth
        }
    }
    
    /// The views borders color
    @IBInspectable var borderColor: NSColor = NSColor.clear {
        didSet {
            self.layer?.borderColor = borderColor.cgColor
        }
    }
    
    /// The views borders radius
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer?.cornerRadius = cornerRadius
        }
    }
    
    /// Prepare the button for Interface Builder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}
