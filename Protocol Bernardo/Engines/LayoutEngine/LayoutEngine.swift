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

	private(set) var documentsController = NSDocumentController()

    /// Creates a new layout and open its window
    func newLayout() {
        _ = try? documentsController.openUntitledDocumentAndDisplay(true)
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
        documentsController.openDocument(withContentsOf: url, display: true) { doc, _, _ in
            guard let doc = doc else { return }

            // Set up autosaving for the document
            doc.scheduleAutosaving()
        }

		App.core.hideHomeWindow()
    }
}
