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
    
    /// Reference to the sidebar
    weak var sidebar: LayoutEditorSidebar!
    
    /// The scene view
    internal var _sceneView: DevicesLayoutView {
        return view as! DevicesLayoutView
    }
    
    
    // //////////////////////////
    // MARK: - Layout properties
    
    /// The layout, initialized as empty
    internal var _layout: Layout!
    
    /// The SKScene used by the editor
    internal var _scene: SKScene!
    
    /// Convenient access to the 'root' node of the scene
    var root: SKNode { return _scene.childNode(withName: "root")! }
    
    /// The scene front layer, holding the device objects
    var frontLayer: SKNode { return _scene.childNode(withName: "root/frontLayer")! }
    
    /// The scene back layer, holding the decorations objects
    var backLayer: SKNode { return _scene.childNode(withName: "root/backLayer")! }
    
    // List of all the elements nodes in the scene
    var elements = [LayoutEditorElement]()
    
    /// The currently selected node, might be null
    weak var selectedNode: LayoutEditorElement? {
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
}


// /////////////////////////
// MARK: - NSViewController
extension LayoutEditor {
    override func viewDidAppear() {
        // Start with a blank layout
        
        // Set up the scene view
        _sceneView.editor = self
        _sceneView.allowsTransparency = true
        
        // Create the scene
        _scene = SKScene(fileNamed: "LayoutEditor")
        
        // Display it
        _sceneView.presentScene(_scene)
        
        // Parse layout to create nodes for existing elements
        _layout.devices.forEach {
            createNodeForExistingDevice($0)
        }
    }
    
    func setLayout(_ layout: Layout) {
        _layout = layout
    }
}


// ////////////////////////////////
// MARK: - Scene elements lifecycle
extension LayoutEditor {
    /// Creates a new node for a new device and insert it in the layotu
    func createDevice() {
        let deviceNode = LayoutEditorDevice(withEditor: self,
                                            forDevice: _layout.createDevice())
        elements.append(deviceNode)
        
        selectedNode = deviceNode
    }
    
    /// Create the node for an existing device
    ///
    /// - Parameter device: The device to create a node for
    func createNodeForExistingDevice(_ device: Device) {
        let deviceNode = LayoutEditorDevice(withEditor: self,
                                            forDevice: device)
        elements.append(deviceNode)
    }
    
    /// Removes the given node fromn the layout and the SKScene
    ///
    /// - Parameter element: The device node holding the node to remove
    func remove(device: LayoutEditorDevice) {
        // Remove from the layout
        _layout.remove(device: device.device)
        
        // Remove from our internal list
        elements.removeAll {
            $0 === device
        }
        
        // The node removes itself from the scene
    }
}