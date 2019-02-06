//
//  LayoutSplitViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutSplitViewController: NSSplitViewController {
    // //////////////////
    // MARK: - Properties
    
    /// Reference to the window
    weak var window: LayoutWindowController!
    
    /// The canvas split view item
    @IBOutlet weak var canvasSplitViewItem: NSSplitViewItem!
    
    /// The sidebar split view item
    @IBOutlet weak var sidebarSplitViewItem: NSSplitViewItem!
    
    /// Convenient access to the canvas
    internal var _canvas: LayoutCanvas {
        return canvasSplitViewItem.viewController as! LayoutCanvas
    }
    
    /// Convenient access to the sidebar
    internal var _sidebar: LayoutSidebar {
        return sidebarSplitViewItem.viewController as! LayoutSidebar
    }
    
    // //////////////////////
    // MARK: - View Lifecycle
    
    override func viewDidAppear() {
        _canvas.delegate = self
        
        _sidebar.canvas = _canvas
    }
    
    /// Set the current layout
    ///
    /// - Parameter layout:
    func setLayout(_ layout: Layout) {
        _canvas.setLayout(layout)
    }
    
    
    // ///////////////////////////////
    // MARK: - Configuration switching
    
    /// Set the layout window configuration to Edition
    func setToEditionConfiguration() {
        _canvas.editable = true
    }
    
    /// Set the layout window configuration to Calibration
    func setToCalibrationConfiguration() {
        _canvas.editable = false
    }
    
    /// Set the layout window configuration to Tracking
    func setToTrackingConfiguration() {
        _canvas.editable = false
        
    }
}

extension LayoutSplitViewController: LayoutCanvasDelegate {
    func canvasWasChanged(_ canvas: LayoutCanvas) {
        window.setDocumentEdited(true)
    }
    
    func canvas(_ canvas: LayoutCanvas, selectionChanged element: LayoutCanvasElement?) {
        _sidebar.setSelectedElement(element)
    }
}
