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
class LayoutViewController: NSViewController {
    // ////////////////////////
    // MARK: - Base properties
    
    /// The scene view
    var sceneView: LayoutCanvasView! {
        return view as? LayoutCanvasView
    }
    
    /// The canvas delegate
    weak var delegate: LayoutCanvasDelegate?
    
    
    // //////////////////////////
    // MARK: - Canvas properties

	/// Reference to the document
	weak var document: LayoutDocument!
    
    /// Reference to the layout
	var layout: Layout {
		return document.layout
	}
    
    /// The SKScene used by the canvas
    private var scene: SKScene!
    
    /// Convenient access to the 'root' node of the scene
    var root: SKNode { return scene.childNode(withName: "root")! }
    
    /// The scene front layer, holding the device objects
    var frontLayer: SKNode { return scene.childNode(withName: "root/frontLayer")! }
    
    /// The scene back layer, holding the decorations objects
    var backLayer: SKNode { return scene.childNode(withName: "root/backLayer")! }
    
    /// The scene front layer, holding the device objects
    var usersLayer: SKNode { return scene.childNode(withName: "root/usersLayer")! }
    
    // List of all the frontElements nodes in the scene
    private(set) var frontElements = [LayoutCanvasDevice]()
    
    // List of all the backElementlements nodes in the scene
    private(set) var backElements = [LayoutCanvasElement]()
    
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
    
    /// The calibration profile used for this canvas
    weak var calibrationProfile: LayoutCalibrationProfile?
    
    
    // /////////////////////
    // MARK: - Canvas status
    
    /// Tell if the canvas is editable
    var isEditable: Bool = true
}


// /////////////////////////
// MARK: - NSViewController
extension LayoutViewController {
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // Set up the scene view
        sceneView.canvas = self
        sceneView.allowsTransparency = true
        
        // Create the scene
        scene = SKScene(fileNamed: "LayoutCanvas")
        scene.delegate = self
        
        // Display it
        sceneView.presentScene(scene)
        
        // Parse layout to create nodes for existing elements
        layout.devices.forEach {
            createNodeForExistingDevice($0)
        }
        
        // Parse layout to create nodes for existing elements
        layout.decorations.forEach {
            createNodeForExistingLine($0)
        }

        // Tell the delegate the layoutView finish its init
		delegate?.canvasDidAppeared(self, document: document)
    }
    
    func selectDevice(withName deviceName: String) {
        let deviceNode = frontElements.filter { $0.name! == deviceName }.first
        deviceNode?.markAsSelected()
    }
}


// ////////////////////////////////
// MARK: - Scene elements lifecycle
extension LayoutViewController {
    /// Creates a new node for a new device and insert it in the layout
    func createDevice() {
		createNodeForExistingDevice(layout.createDevice())
    }
    
    /// Create the node for an existing device
    ///
    /// - Parameter device: The device to create a node for
    func createNodeForExistingDevice(_ device: Device) {
        let deviceNode = LayoutCanvasDevice(onCanvas: self,
                                            forDevice: device)
        deviceNode.delegate = self
        frontElements.append(deviceNode)

        selectedNode = deviceNode

		document.markAsEdited()
		delegate?.canvas(self, didChange: document)
    }
    
    /// Creates a new node for a new device and insert it in the layotu
    func createLine() {
		createNodeForExistingLine(layout.createLine())
    }
    
    /// Create the node for an existing device
    ///
    /// - Parameter device: The device to create a node for
    func createNodeForExistingLine(_ line: Line) {
        let lineNode = LayoutCanvasLine(onCanvas: self,
                                        forLine: line)
        lineNode.delegate = self
        backElements.append(lineNode)

		document.markAsEdited()
		delegate?.canvas(self, didChange: document)
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
		document.markAsEdited()
		delegate?.canvas(self, didChange: document)
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
		document.markAsEdited()
		delegate?.canvas(self, didChange: document)
    }
}

extension LayoutViewController: LayoutCanvasElementDelegate {
    func elementDidChange(_: LayoutCanvasElement) {
		document.markAsEdited()
		delegate?.canvas(self, didChange: document)
    }
    
    func elementWillBeRemoved(_ element: LayoutCanvasElement) {
        if element is LayoutCanvasDevice {
            remove(device: element as! LayoutCanvasDevice)
        } else {
            remove(line: element as! LayoutCanvasLine)
        }
    }
    
    func elementCanBeEdited(_: LayoutCanvasElement) -> Bool {
        return self.isEditable
    }

    func element(_ element: LayoutCanvasElement, selectionChanged _: Bool) {
        selectedNode = element
    }

    func duplicateDeviceElement(_ element: LayoutCanvasDevice) {
        let newDevice = Device(from: element.device)

        newDevice.position.x += 10
        newDevice.position.y += 10

        layout.devices.append(newDevice)
        createNodeForExistingDevice(newDevice)
    }

    func duplicateLineElement(_ element: LayoutCanvasLine) {
        let newLine = Line(from: element.line)

        layout.decorations.append(newLine)
        createNodeForExistingLine(newLine)
    }

    func canvasRootNode() -> SKNode {
        return root
    }

    func canvasWindow() -> NSWindow {
        return self.view.window!
    }

    func deviceProfile(forDevice device: Device) -> DeviceCalibrationProfile? {
        return self.calibrationProfile?.device(forUUID: device.uuid)
    }
}

// MARK: - SKSceneDelegate
extension LayoutViewController: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        // Pass the update event to all the devices
        frontElements.forEach { $0.update() }

        // Update the users array
        usersLayer.removeAllChildren()
        
        // For all actively tracked users
        for user in App.usersEngine.users {
            guard user.physicsHistory.count > 0 else { continue }

            // Create a node for it
            let userNode = LayoutCanvasUser(user: user)
            
            // And display it
            usersLayer.addChild(userNode)
        }
    }
}
