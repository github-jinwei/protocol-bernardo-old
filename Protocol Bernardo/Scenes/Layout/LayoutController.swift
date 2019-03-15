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

        // Adjust the transition animation
//        if tabViewController.selectedTabViewItemIndex < interfaceMode.rawValue {
//            tabViewController.transitionOptions = .slideForward
//        } else {
//            tabViewController.transitionOptions = .slideBackward
//        }

        // Change the sidebar
        tabViewController.selectedTabViewItemIndex = interfaceMode.rawValue

        // Do more adjustement if needed
        switch interfaceMode {
        case .edition: break
        case .calibration:

            let sidebar = (self.sidebar as! LayoutSidebarCalibration)
            sidebar.document = layoutDocument
            sidebar.profile = calibrationProfile
        case .tracking:
            let sidebar = (self.sidebar as! LayoutSidebarTracking)
            sidebar.document = layoutDocument
            sidebar.profile = calibrationProfile
        }

        canvas.isEditable = interfaceMode == .edition
    }

    func toolbar(_ layoutWindow: LayoutWindowController, calibrationProfileChanged profile: LayoutCalibrationProfile?) {
        calibrationProfile = profile
        layoutDocument.layout.profile = profile!.name

        App.usersEngine.profile = calibrationProfile
        App.usersEngine.layout = layoutDocument.layout

        canvas.calibrationProfile = calibrationProfile
        sidebar.setCalibrationProfile(calibrationProfile)

        layoutDocument.markAsEdited()
    }

    func createNewDevice(_: LayoutWindowController) {
        canvas.createDevice()
    }

    func createNewLine(_: LayoutWindowController) {
        canvas.createLine()
    }

    func clearDeviceDeltas(_: LayoutWindowController) {
        guard let sidebar = sidebar as? LayoutSidebarCalibration else {
            return
        }

        sidebar.clearDeltas(nil)
    }

    func updateDeviceDeltas(_: LayoutWindowController) {
        guard let sidebar = sidebar as? LayoutSidebarCalibration else {
            return
        }

        sidebar.storeDeltas(nil)
    }
}


// ////////////////////////////
// MARK: - LayoutCanvasDelegate
extension LayoutController: LayoutCanvasDelegate {
    func canvasAppeared(_: LayoutCanvas) {
//        window.setDocumentEdited(false)
    }

    func canvasWasChanged(_: LayoutCanvas) {
        layoutDocument.markAsEdited()
    }
    
    func canvas(_: LayoutCanvas, selectionChanged element: LayoutCanvasElement?) {
        sidebar.setSelectedElement(element)
    }
}
