//
//  DevicesLayoutEditorScene.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEditorScene {
    // ////////////////////////////////////
    // MARK: Inherited elements from Scene
    var sceneIndex: Int!
    static var sceneName = "Layout Editor"
    static var sceneDescription = "Create and edit devices layout to map real-world installations."
    
    // /////////////////
    // MARK: - Properties
    
    var _document: LayoutDocument!
    
    // ////////////////
    // Scene Lifecycle
    
}

extension LayoutEditorScene: Scene {
    static func make() -> Scene {
        return LayoutEditorScene()
    }
    
    /// Sets the layout document to work with
    ///
    /// - Parameter document:
    func setLayoutDocument(_ document: LayoutDocument) {
        _document = document
//        LayoutDocument.opentin
    }
}
