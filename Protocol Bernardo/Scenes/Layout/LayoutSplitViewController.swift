//
//  LayoutSplitViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutSplitViewController: NSSplitViewController {
    // ///////////
    // Properties
    
    weak var window: LayoutWindowController!
    
    @IBOutlet weak var canvasSplitViewItem: NSSplitViewItem!
    @IBOutlet weak var sidebarSplitViewItem: NSSplitViewItem!
    
    var sidebar: LayoutEditorSidebar {
        return sidebarSplitViewItem.viewController as! LayoutEditorSidebar
    }
    
    var canvas: LayoutCanvas {
        return canvasSplitViewItem.viewController as! LayoutCanvas
    }
    
    // ///////////////
    // View Lifecycle
    
    override func viewDidAppear() {
        canvas.delegate = self
        
        sidebar.canvas = canvas
    }
    
    /// Set the current layout
    ///
    /// - Parameter layout:
    func setLayout(_ layout: Layout) {
        canvas.setLayout(layout)
    }
}

extension LayoutSplitViewController: LayoutCanvasDelegate {
    func canvasWasChanged(_ canvas: LayoutCanvas) {
        window.setDocumentEdited(true)
    }
    
    func canvas(_ canvas: LayoutCanvas, selectionChanged element: LayoutCanvasElement?) {
        if element == nil {
            sidebar.clear()
            return
        }
        
        sidebar.displayParameters(ofElement: element!)
    }
}
