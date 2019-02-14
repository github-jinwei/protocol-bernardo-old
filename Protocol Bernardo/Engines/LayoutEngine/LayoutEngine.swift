//
//  LayoutEngine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// The layout engine handles creating and opening layouts
class LayoutEngine {
    /// Creates a new layout and open its window
    func newLayout() {
        _ = try? App.documentsController.openUntitledDocumentAndDisplay(true)
    }

    /// Ask the user to select a pblayout and opens it
    func openLayout() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["pblayout"]
        openPanel.runModal()

        guard let fileURL = openPanel.url else { return }

        openLayout(at: fileURL)
    }
    
    /// Open the pblayout at the given url
    ///
    /// - Parameter url: A .pblayout package url
    func openLayout(at url: URL) {
        App.documentsController.openDocument(withContentsOf: url, display: true) { _, _, _ in }
    }
}
