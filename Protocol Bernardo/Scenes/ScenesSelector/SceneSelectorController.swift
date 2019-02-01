//
//  SceneSelectorController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-19.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Cocoa

/// The `Scene Selector` is the first window that appears at the start of the app.
///
/// It displays a list of the scene the user can start. These scenes are defined
/// in the `availableScenes` array, and must conform the `Scene` protocol.
class SceneSelectorController: NSViewController {
    @IBOutlet weak var scenesList: NSStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        // Register ourselves in the Core to allow for future reopening
        App.core.registerSceneSelectorController(self)

        // View is loaded, lets load the scenes list and display it
        availableScenes.forEach {
            let sceneView: PBSceneButton = NSNib.make(fromNib: "PBSceneButton", owner: nil)
            
            sceneView.sceneNameField.stringValue = $0.sceneName
            sceneView.sceneDescriptionField.stringValue = $0.sceneDescription
            sceneView.sceneType = $0
            
            scenesList.addView(sceneView, in: .top)
        }
        
        (scenesList.views.first as! PBSceneButton).separatorLine.removeFromSuperview()
    }
    
    override func viewDidAppear() {
        // Set the window title
        self.view.window?.title = "Protocol Bernardo"
        
        // And the window size
        view.window!.setContentSize(scenesList.fittingSize)
    }
}

