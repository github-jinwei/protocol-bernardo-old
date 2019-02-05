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
        _ = try? App.documentsController.openUntitledDocumentAndDisplay(true)
    }
    
    func openLayout(at url: URL) {
        App.documentsController.openDocument(withContentsOf: url, display: true) { _,_,_ in }
    }
}
