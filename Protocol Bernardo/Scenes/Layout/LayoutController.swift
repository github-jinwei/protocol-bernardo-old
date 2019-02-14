//
//  LayoutController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutController: NSSplitViewController {
    // //////////////////
    // MARK: - Properties
    
    /// The canvas split view item
    @IBOutlet weak var canvasSplitViewItem: NSSplitViewItem!
    
    /// The sidebar split view item
    @IBOutlet weak var sidebarTabViewItem: NSSplitViewItem!

    /// Reference to the window
    var window: LayoutWindowController!

    /// The layout document
    var layoutDocument: LayoutDocument {
        return window.layoutDocument
    }
    
    /// The opened calibration profile, if any
    var calibrationProfile: LayoutCalibrationProfile?
    
    
    // ///////////////////////////////
    // MARK: - Convenience properties
    
    /// Convenient access to the canvas
    internal var _canvas: LayoutCanvas {
        return canvasSplitViewItem.viewController as! LayoutCanvas
    }
    
    /// Convenient access to the sidebar
    internal var _sidebar: LayoutSidebar {
        let tabIndex = (sidebarTabViewItem.viewController as! NSTabViewController).selectedTabViewItemIndex
        return (sidebarTabViewItem.viewController as! NSTabViewController).tabViewItems[tabIndex].viewController as! LayoutSidebar
    }
}



// //////////////////////
// MARK: - View Lifecycle
extension LayoutController {
    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarTabViewItem.minimumThickness = 252
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

        // Mark ourselves as the layout window delegate
        window.delegate = self
        
        _canvas.layout = (window.document as? LayoutDocument)?.layout
        _canvas.delegate = self

        for sidebar in (sidebarTabViewItem.viewController as! NSTabViewController).tabViewItems {
            let layoutSidebar = sidebar.viewController as! LayoutSidebar
            layoutSidebar.canvas = _canvas
        }
    }
}



// ///////////////////////////////
// MARK: - Configuration switching
extension LayoutController: LayoutWindowDelegate {
    func toolbar(_ layoutWindow: LayoutWindowController, interfaceModeHasChanged interfaceMode: LayoutInterfaceMode) {
        let tabViewController = sidebarTabViewItem.viewController as! NSTabViewController

        switch interfaceMode {
        case .edition:
            tabViewController.selectedTabViewItemIndex = 0
        case .calibration:
            tabViewController.selectedTabViewItemIndex = 1

            let sidebar = _sidebar as! LayoutSidebarCalibration
            sidebar.document = layoutDocument
            sidebar.profile = calibrationProfile

        case .tracking:
            tabViewController.selectedTabViewItemIndex = 2
        }
    }

    func toolbar(_ layoutWindow: LayoutWindowController, calibrationProfileChanged profile: LayoutCalibrationProfile?) {

        calibrationProfile = profile

        App.usersEngine.profile = calibrationProfile
        App.usersEngine.layout = layoutDocument.layout

        _canvas.calibrationProfile = calibrationProfile
        _sidebar.setCalibrationProfile(calibrationProfile)

    }
}

extension LayoutController: LayoutCanvasDelegate {
    func canvasAppeared(_ canvas: LayoutCanvas) {
        window.setDocumentEdited(false)
    }

    func canvasWasChanged(_ canvas: LayoutCanvas) {
        window.setDocumentEdited(true)
    }
    
    func canvas(_ canvas: LayoutCanvas, selectionChanged element: LayoutCanvasElement?) {
        _sidebar.setSelectedElement(element)
    }
}
