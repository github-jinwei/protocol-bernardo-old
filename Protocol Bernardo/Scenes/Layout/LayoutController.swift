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
    private var canvas: LayoutCanvas {
        return canvasSplitViewItem.viewController as! LayoutCanvas
    }
    
    /// Convenient access to the sidebar
    private var sidebar: LayoutSidebar {
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
        
        canvas.layout = (window.document as! LayoutDocument).layout
        canvas.delegate = self

        for sidebar in (sidebarTabViewItem.viewController as! NSTabViewController).tabViewItems {
            let layoutSidebar = sidebar.viewController as! LayoutSidebar
            layoutSidebar.canvas = canvas
        }

        if layoutDocument.layout.profile != nil {
            window.calibrationProfilesList.selectItem(withTitle: layoutDocument.layout.profile!)
            window.setCalibrationProfile(window.calibrationProfilesList)
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

            canvas.isEditable = true
        case .calibration:
            tabViewController.selectedTabViewItemIndex = 1

            let sidebar = (self.sidebar as! LayoutSidebarCalibration)
            sidebar.document = layoutDocument
            sidebar.profile = calibrationProfile

            canvas.isEditable = false

        case .tracking:
            tabViewController.selectedTabViewItemIndex = 2

            canvas.isEditable = false
        }
    }

    func toolbar(_ layoutWindow: LayoutWindowController, calibrationProfileChanged profile: LayoutCalibrationProfile?) {
        calibrationProfile = profile
        layoutDocument.layout.profile = profile!.name

        App.usersEngine.profile = calibrationProfile
        App.usersEngine.layout = layoutDocument.layout

        canvas.calibrationProfile = calibrationProfile
        sidebar.setCalibrationProfile(calibrationProfile)

        window.setDocumentEdited(true)
    }
}


// ////////////////////////////
// MARK: - LayoutCanvasDelegate
extension LayoutController: LayoutCanvasDelegate {
    func canvasAppeared(_: LayoutCanvas) {
        window.setDocumentEdited(false)
    }

    func canvasWasChanged(_: LayoutCanvas) {
        window.setDocumentEdited(true)
    }
    
    func canvas(_: LayoutCanvas, selectionChanged element: LayoutCanvasElement?) {
        sidebar.setSelectedElement(element)
    }
}
