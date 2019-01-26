
//
//  Scene.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

protocol Scene {
    /// Name of the scene, to display on the scene selection screen
    static var sceneName: String { get }

    /// Description for the scenem to display on the scene selection screen
    static var sceneDescription: String { get }
    
    /// Intializer called when the scene is loaded
    static func make() -> Scene
    
    /// Index of the scene inside the Core. This is used to properly remove the scene from the Core. This value should not be edited
    var sceneIndex: Int! { get set }
}

// MARK: - Prefill methods
extension Scene {
    /// This method properly remove the scene from the scene index.
    ///
    /// You do not need to implement this method, but if you do, make sure to call it at the end of your own implementation.
    /// The removal of the scene from the scene also triggers its deinit, which you can use to properly
    /// free what needs to be from your scene
    func endScene() {
        // Remove the scene from the scenes index
        App.core.removeScene(withIndex: sceneIndex)
    }
}

// MARK: - Convenient methods
extension Scene {
    /// Create and open a window
    ///
    /// - Parameters:
    ///   - storyboardName: Name of the storyboard the window is in
    ///   - windowID: Identifier of the window
    /// - Returns: The windowController of the newly created window
    func makeWindow<WindowController: NSWindowController>(onStoryboard storyboardName: String, withIdentifier windowID: String) -> WindowController {
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: windowID) as! WindowController
        windowController.showWindow(nil)
        
        return windowController
    }
}
