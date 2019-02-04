//
//  Core.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// The application structure Core
class Core {
    /// Reference to the SceneSelectorController
    internal var _sceneSelectorController: WelcomeSceneViewController!
    
    /// Used by the SceneSelectorController to register itself
    ///
    /// - Parameter controller: The SceneSelectorController
    func registerSceneSelectorController(_ controller: WelcomeSceneViewController) {
        _sceneSelectorController = controller
    }
    
    func openSceneSelector() {
        _sceneSelectorController!.view.window!.windowController!.showWindow(nil)
    }
    
    /// Array with all the currently opened scenes
    internal var _scenes = [Int: Scene]()
    
    /// The index of the next scene that will be added
    internal var _nextSceneIndex: Int = 0
    
    /// Instanciate and register a new scene
    ///
    /// - Parameter sceneType: The Type of the scene to create
    func makeScene(ofType sceneType: Scene.Type) {
        var newScene = sceneType.make()
        newScene.sceneIndex = _nextSceneIndex
        
        _scenes[_nextSceneIndex] = newScene
        
        _nextSceneIndex += 1
    }
    
    /// Deregister a scene. If the scene has no other references,
    /// this will triggers its deinit
    ///
    /// - Parameter sceneIndex: Index of the scene to remove
    func removeScene(withIndex sceneIndex: Int) {
        _scenes.removeValue(forKey: sceneIndex)
        
        if(_scenes.count == 0) {
            openSceneSelector()
        }
    }
}
