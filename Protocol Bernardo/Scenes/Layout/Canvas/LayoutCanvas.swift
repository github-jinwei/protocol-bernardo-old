//
//  LayoutCanvas.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit
import SpriteKit

/// This view represent the given layout using a SpriteKitScene
class LayoutCanvas: NSViewController {
    // ////////////////////////
    // MARK: - Base properties
    
    /// The scene view
    internal var _sceneView: LayoutCanvasView {
        return view as! LayoutCanvasView
    }
    
    weak var delegate: LayoutCanvasDelegate?
    
    
    // //////////////////////////
    // MARK: - Canvas properties
    
    /// The layout, initialized as empty
    internal weak var _layout: Layout!
    
    /// The SKScene used by the canvas
    internal var _scene: SKScene!
    
    /// Convenient access to the 'root' node of the scene
    var root: SKNode { return _scene.childNode(withName: "root")! }
    
    /// The scene front layer, holding the device objects
    var frontLayer: SKNode { return _scene.childNode(withName: "root/frontLayer")! }
    
    /// The scene back layer, holding the decorations objects
    var backLayer: SKNode { return _scene.childNode(withName: "root/backLayer")! }
    
    // List of all the elements nodes in the scene
    var elements = [LayoutCanvasElement]()
    
    /// The currently selected node, might be null
    weak var selectedNode: LayoutCanvasElement? {
        willSet(node) {
            if selectedNode === node { return }
            
            // Deselect the currently selected node (if any) before moving on
            selectedNode?.deselect()
            node?.select()
        }
    }
    
    
    // /////////////////////
    // MARK: - Canvas status
    
    var editable: Bool = true
    
    var edited: Bool = false
}


// /////////////////////////
// MARK: - NSViewController
extension LayoutCanvas {
    override func viewDidAppear() {
        // Start with a blank layout
        
        // Set up the scene view
        _sceneView.canvas = self
        _sceneView.allowsTransparency = true
        
        // Create the scene
        _scene = SKScene(fileNamed: "LayoutCanvas")
        
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
extension LayoutCanvas {
    /// Creates a new node for a new device and insert it in the layotu
    func createDevice() {
        let deviceNode = LayoutCanvasDevice(onCanvas: self,
                                            forDevice: _layout.createDevice())
        deviceNode.delegate = self
        elements.append(deviceNode)
        
        selectedNode = deviceNode
        
        delegate?.canvasWasChanged(self)
    }
    
    /// Create the node for an existing device
    ///
    /// - Parameter device: The device to create a node for
    func createNodeForExistingDevice(_ device: Device) {
        let deviceNode = LayoutCanvasDevice(onCanvas: self,
                                            forDevice: device)
        deviceNode.delegate = self
        elements.append(deviceNode)
        
        delegate?.canvasWasChanged(self)
    }
    
    /// Removes the given node fromn the layout and the SKScene
    ///
    /// - Parameter element: The device node holding the node to remove
    func remove(device: LayoutCanvasDevice) {
        // Remove from the layout
        _layout.remove(device: device.device)
        
        // Remove from our internal list
        elements.removeAll {
            $0 === device
        }
        
        // The node removes itself from the scene
        delegate?.canvasWasChanged(self)
    }
}

extension LayoutCanvas: LayoutCanvasElementDelegate {
    func elementDidChange(_ element: LayoutCanvasElement) {
        delegate?.canvasWasChanged(self)
    }
    
    func elementWillBeRemoved(_ element: LayoutCanvasElement) {
        delegate?.canvasWasChanged(self)
    }
}
