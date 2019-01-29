//
//  LayoutEditor.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit
import SpriteKit

class LayoutEditor: NSViewController {
    // ////////////////////////
    // MARK: - Base properties
    /// Reference to the scene window
    weak var window: DevicesLayoutEditor!
    
    /// Reference to the sidebar
    weak var sidebar: LayoutEditorSidebar!
    
    /// The scene view
    internal var _sceneView: DevicesLayoutView {
        return view as! DevicesLayoutView
    }
    
    
    // //////////////////////////
    // MARK: - Layout properties
    
    /// The layout, inited as empty
    internal var _layout = DevicesLayout()
    
    /// The SKScene used by the editor
    internal var _scene: SKScene!
    
    var root: SKNode { return _scene.childNode(withName: "root")! }
    
    /// The scene front layer, holding the device objects
    var frontLayer: SKNode { return _scene.childNode(withName: "root/frontLayer")! }
    
    /// The scene back layer, holding the decorations objects
    var backLayer: SKNode { return _scene.childNode(withName: "root/backLayer")! }
    
    /// The currently selected node, might be null
    var selectedNode: LayoutElement? {
        willSet(node) {
            // Deselect the currently selected node (if any) before moving on
            selectedNode?.deselect()
            node?.select()
        }
    }
}


// /////////////////////////
// MARK: - NSViewController
extension LayoutEditor {
    override func viewDidAppear() {
        // Start with a blank layout
        
        // Open welcome screen
        performSegue(withIdentifier: "openWelcomeModal", sender: self)
        
        // Set up the scene view
        _sceneView.editor = self
        _sceneView.allowsTransparency = true
        
        // Create the scene
        _scene = SKScene(fileNamed: "LayoutEditor")
        
        // And display it
        _sceneView.presentScene(_scene)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if(segue.destinationController is WelcomeViewController) {
            let welcomeView = segue.destinationController as! WelcomeViewController
            
            welcomeView.editor = self
        }
    }
    
    /// Tell the window to end the scene
    func close() {
        window.endScene()
    }
}


// ////////////////////////////////
// MARK: - Scene elements creation
extension LayoutEditor {
    /// Creates a new device and insert it in the layout
    func addDevice() {
        let device = LayoutElementDevice(withEditor: self,
                                         withExistingDevice: nil)
        _layout.elements.append(device)
        selectedNode = device
    }
}


// ///////////////////
// MARK: - User Events
extension LayoutEditor {
    override func mouseDown(with event: NSEvent) {
        // If we received this event, it means a click was made on nothing.
        // Let's deselect the possibly selected node
        selectedNode = nil
    }
    
    override func scrollWheel(with event: NSEvent) {
        root.position.x += event.scrollingDeltaX
        root.position.y -= event.scrollingDeltaY
    }
    
    override func magnify(with event: NSEvent) {
        let scale = (root.xScale + event.magnification).clamped(to: 0.25...1)
        root.xScale = scale
        root.yScale = scale
    }
}
