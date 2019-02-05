//
//  PositionsCollector.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit
import Repeat

class DevicesScene: Scene {
    // /////////////////////////
    // MARK: Inherited elements
    var sceneIndex: Int!
    static var sceneName = "Positions Collector"
    static var sceneDescription = "Gather users positions from connected devices"
    
    static func make() -> Scene {
        return DevicesScene()
    }
    
    
    // /////////////////
    // MARK: Properties
    
    /// The window handled by this scene
    internal var _windowController: DevicesSceneWindowController!
    
    /// The main viewController
    internal weak var _viewController: DevicesSceneViewController!
    
    /// The closing timer (Used for cosmetics)
    internal var _closingTimer: Repeater?
    
    
    // ////////////////
    // Scene Lifecycle
    
    /// Create the window for interactions and init the dae
    init() {
        // Create the window
        _windowController = makeWindow(onStoryboard: "DevicesScene", withIdentifier: "DevicesSceneWindow")
        _windowController.movementsCollector = self
        _viewController = _windowController.contentViewController! as? DevicesSceneViewController
        _viewController.movementsCollector = self
        
        // Init the DAE on the CPP side
        App.dae.delegate = self
        App.dae.start()
    }
    
    /// Asks the DAE to refresh the available devices list
    func refreshDevicesList() {
        App.dae.refreshDevicesList()
    }
    
    /// Ends the DAE activities before closing the scene
    func endScene() {
        App.dae.end()
        (self as Scene).endScene()
    }
}

// MARK: - DataAcquisitionEngineDelegate
extension DevicesScene: DataAcquisitionEngineDelegate {
    func dae(_ dae: DataAcquisitionEngine, statusUpdated status: DAEStatus) {
        DispatchQueue.main.async {
           self._viewController.statusUpdate(status);
        }
    }
}