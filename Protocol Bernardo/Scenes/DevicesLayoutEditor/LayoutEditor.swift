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
    weak var window: DevicesLayoutEditorScene!
    
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
    
    var elements: [LayoutElement] { return _layout.elements }
    
    /// The SKScene used by the editor
    internal var _scene: SKScene!
    
    var root: SKNode { return _scene.childNode(withName: "root")! }
    
    /// The scene front layer, holding the device objects
    var frontLayer: SKNode { return _scene.childNode(withName: "root/frontLayer")! }
    
    /// The scene back layer, holding the decorations objects
    var backLayer: SKNode { return _scene.childNode(withName: "root/backLayer")! }
    
    /// The currently selected node, might be null
    weak var selectedNode: LayoutElement? {
        willSet(node) {
            if selectedNode === node { return }
            
            // Deselect the currently selected node (if any) before moving on
            selectedNode?.deselect()
            node?.select()
            
            // Clear the sidebar
            sidebar.clear()
            
            if node != nil {
                // Display the parameters for the selected element
                sidebar.displayParameters(ofElement: node!)
            }
        }
    }
    
    
    // //////////////////////////////////
    // MARK: Keyboard listener properties
    
    var shiftPressed: Bool = false
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
// MARK: - Scene elements lifecycle
extension LayoutEditor {
    /// Creates a new device and insert it in the layout
    func addDevice() {
        let device = LayoutElementDevice(withEditor: self,
                                         withExistingDevice: nil)
        _layout.elements.append(device)
        selectedNode = device
    }
    
    func remove(element: LayoutElement) {
        _layout.elements.remove(at: _layout.elements.firstIndex(where: {
            $0 === element
        })!)
    }
}
