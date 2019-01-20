
//
//  Scene.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol Scene {
    /// Name of the scene, to display on the scene selection screen
    static var sceneName: String { get }

    /// Description for the scenem to display on the scene selection screen
    static var sceneDescription: String { get }
    
    /// Intializer called when the scene is loaded
    init()
    
    /// Index of the scene inside the Core. This is used to properly remove the scene from the Core. This value should not be edited
    var sceneIndex: Int { get set }
    
    func endScene()
}

extension Scene {
    func endScene() {
        App.core.removeScene(withIndex: sceneIndex)
    }
}
