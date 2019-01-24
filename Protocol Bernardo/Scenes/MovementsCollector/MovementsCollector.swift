//
//  MovementsCollector.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit
import Repeat

class MovementsCollector: Scene {
    // /////////////////////////
    // MARK: Inherited elements
    var sceneIndex: Int!
    static var sceneName = "Movements Collector"
    static var sceneDescription = "Gather people movements from connected devices"
    
    static func make() -> Scene {
        return MovementsCollector()
    }
    
    // MARK: Properties
    
    /// The window handled by this scene
    internal var _windowController: MovementsCollectorWindowController!
    
    /// The main viewController
    internal weak var _viewController: MovementsCollectorViewController!
    
    /// The closing timer (Used for cosmetics)
    internal var _closingTimer: Repeater?
    
    /// Create the window for interactions and init the dae
    init() {
        // Create the window
        _windowController = makeWindow(onStoryboard: "MovementsCollector", withIdentifier: "MovementsCollectorWindow")
        _windowController.movementsCollector = self
        _viewController = _windowController.contentViewController! as? MovementsCollectorViewController
        _viewController.movementsCollector = self
        
        // Init the DAE on the CPP side
        App.dae.delegate = self
        App.dae.start()
    }
    
    func refreshDevicesList() {
        App.dae.refreshDevicesList()
    }
    
    func endScene() {
        App.dae.end()
        (self as Scene).endScene()
    }
    
    // ///////////////////
    // MARK: Device Lifecycle
}

extension MovementsCollector: DataAcquisitionEngineDelegate {
    func dae(_ dae: DataAcquisitionEngine, statusUpdated status: DAEStatus) {
        DispatchQueue.main.async {
           self._viewController.statusUpdate(status);
        }
    }
}
