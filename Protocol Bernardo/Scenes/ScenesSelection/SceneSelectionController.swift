//
//  ViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

class SceneSelectionController: NSViewController, Scene {
    
    var sceneIndex: Int = -1
    
    static let sceneName: String = "Scene Selection"
    
    static let sceneDescription: String = "Used to open new scenes"

    @IBOutlet weak var scenesList: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // View is loaded, lets load the scenes list and display it
        availableScenes.forEach {
            let sceneView: PBSceneButton = NSView.make(fromNib: "PBSceneButton", owner: nil)
            
            sceneView.sceneNameField.stringValue = $0.sceneName
            sceneView.sceneDescriptionField.stringValue = $0.sceneDescription
            sceneView.sceneType = $0
            
            scenesList.addView(sceneView, in: .top)
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.title = "Protocol Bernardo"
    }
}

