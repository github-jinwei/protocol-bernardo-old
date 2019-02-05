//
//  LayoutEngine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEngine {
    func newLayout() {
        let newDocument = try! App.documentsController.openUntitledDocumentAndDisplay(true) as! LayoutDocument
        
        let layoutScene = App.core.makeScene(ofType: LayoutEditorScene.self) as! LayoutEditorScene
        layoutScene.setLayoutDocument(newDocument)
        
    }
    
    func openLayout(at url: URL) {
        App.documentsController.openDocument(withContentsOf: url, display: true) { document, _, _ in
            let layoutScene = App.core.makeScene(ofType: LayoutEditorScene.self) as! LayoutEditorScene
            layoutScene.setLayoutDocument(document! as! LayoutDocument)
        }
    }
}
