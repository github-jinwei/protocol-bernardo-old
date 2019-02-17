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
    weak var layout: Layout!
    
    /// The SKScene used by the canvas
    internal var _scene: SKScene!
    
    /// Convenient access to the 'root' node of the scene
    var root: SKNode { return _scene.childNode(withName: "root")! }
    
    /// The scene front layer, holding the device objects
    var frontLayer: SKNode { return _scene.childNode(withName: "root/frontLayer")! }
    
    /// The scene back layer, holding the decorations objects
    var backLayer: SKNode { return _scene.childNode(withName: "root/backLayer")! }
    
    /// The scene front layer, holding the device objects
    var usersLayer: SKNode { return _scene.childNode(withName: "root/usersLayer")! }
    
    // List of all the frontElements nodes in the scene
    var frontElements = [LayoutCanvasDevice]()
    
    // List of all the backElementlements nodes in the scene
    var backElements = [LayoutCanvasElement]()
    
    /// The currently selected node, might be null
    var selectedNode: LayoutCanvasElement? {
        didSet {
            if selectedNode === oldValue {
                return
            }
            
            // Deselect the currently selected node (if any) before moving on
            oldValue?.deselect()
            selectedNode?.select()
            
            delegate?.canvas(self, selectionChanged: selectedNode)
        }
    }
    
    weak var calibrationProfile: LayoutCalibrationProfile?
    
    
    // /////////////////////
    // MARK: - Canvas status
    
    /// Tell if the canvas is editable
    var isEditable: Bool = true
}


// /////////////////////////
// MARK: - NSViewController
extension LayoutCanvas {
    override func viewDidAppear() {
        super.viewDidAppear()
        // Start with a blank layout
        
        // Set up the scene view
        _sceneView.canvas = self
        _sceneView.allowsTransparency = true
        
        // Create the scene
        _scene = SKScene(fileNamed: "LayoutCanvas")
        _scene.delegate = self
        
        // Display it
        _sceneView.presentScene(_scene)
        
        // Parse layout to create nodes for existing elements
        layout.devices.forEach {
            createNodeForExistingDevice($0)
        }
        
        // Parse layout to create nodes for existing elements
        layout.decorations.forEach {
            createNodeForExistingLine($0)
        }

        // Tell the delegate the canvas finish its init
        delegate?.canvasAppeared(self)
    }
    
    func selectDevice(withName deviceName: String) {
        let deviceNode = frontElements.filter { $0.name! == deviceName }.first
        deviceNode?.markAsSelected()
    }
}


// ////////////////////////////////
// MARK: - Scene elements lifecycle
extension LayoutCanvas {
    /// Creates a new node for a new device and insert it in the layout
    func createDevice() {
        let deviceNode = LayoutCanvasDevice(onCanvas: self,
                                            forDevice: layout.createDevice())
        deviceNode.delegate = self
        frontElements.append(deviceNode)
        
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
        frontElements.append(deviceNode)
        
        delegate?.canvasWasChanged(self)
    }
    
    /// Creates a new node for a new device and insert it in the layotu
    func createLine() {
        let deviceNode = LayoutCanvasLine(onCanvas: self,
                                          forLine: layout.createLine())
        deviceNode.delegate = self
        backElements.append(deviceNode)
        
        selectedNode = deviceNode
        
        delegate?.canvasWasChanged(self)
    }
    
    /// Create the node for an existing device
    ///
    /// - Parameter device: The device to create a node for
    func createNodeForExistingLine(_ line: Line) {
        let lineNode = LayoutCanvasLine(onCanvas: self,
                                        forLine: line)
        lineNode.delegate = self
        backElements.append(lineNode)
        
        delegate?.canvasWasChanged(self)
    }
    
    /// Removes the given device from the layout and the SKScene
    ///
    /// - Parameter device: The device node holding the device to remove
    func remove(device: LayoutCanvasDevice) {
        // Remove from the layout
        layout.remove(device: device.device)
        
        // Remove from our internal list
        frontElements.removeAll {
            $0 === device
        }
        
        // The node removes itself from the scene
        delegate?.canvasWasChanged(self)
    }
    
    /// Removes the given line from the layout and the SKScene
    ///
    /// - Parameter element: The line node holding the line to remove
    func remove(line: LayoutCanvasLine) {
        // Remove from the layout
        layout.remove(line: line.line)
        
        // Remove from our internal list
        backElements.removeAll {
            $0 === line
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
    
    func elementCanBeEdited(_ element: LayoutCanvasElement) -> Bool {
        return self.isEditable
    }
}

extension LayoutCanvas: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        // Call the update method of each device
        frontElements.forEach { $0.update() }
        
        // Update the users array
        usersLayer.removeAllChildren()
        
        // For all actively tracked users
        App.usersEngine.allUsers.forEach { user in
            // Create a node for it
            let userNode = LayoutCanvasUser(user: user)
            
            // And display it
            usersLayer.addChild(userNode)
        }
    }
}
