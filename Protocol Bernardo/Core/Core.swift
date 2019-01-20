//
//  Core.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Core {
    
    internal var _scenes = [Scene]()
    
    /// Instanciate and register a new scene
    ///
    /// - Parameter sceneType: The Type of the scene to create
    func makeScene(ofType sceneType: Scene.Type) {
        var newScene = sceneType.init()
        newScene.sceneIndex = _scenes.count
        
        _scenes.append(newScene)
    }
    
    /// Deregister a scene. If the scene has no other references,
    /// this will triggers its deinit
    ///
    /// - Parameter sceneIndex: Index of the scene to remove
    func removeScene(withIndex sceneIndex: Int) {
        _scenes.remove(at: sceneIndex)
    }
}
