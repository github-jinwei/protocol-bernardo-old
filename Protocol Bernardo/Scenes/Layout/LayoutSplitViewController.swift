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
    @IBOutlet weak var sidebarTabViewItem: NSSplitViewItem!
    
    /// The layout document
    var layoutDocument: LayoutDocument {
        return window.layoutDocument
    }
    
    /// The opened calibration profile, if any
    var _calibrationDocument: LayoutCalibrationDocument?
    
    /// The opened calibration profile, if any
    var calibrationDocument: LayoutCalibrationDocument? {
        return _calibrationDocument
    }
    
    
    // ///////////////////////////////
    // MARK: - Convenience properties
    
    /// Convenient access to the tab view controller
    internal var _sidebarTabViewController: NSTabViewController {
        return sidebarTabViewItem.viewController as! NSTabViewController
    }
    
    /// Convenient access to the canvas
    internal var _canvas: LayoutCanvas {
        return canvasSplitViewItem.viewController as! LayoutCanvas
    }
    
    /// Convenient access to the sidebar
    internal var _sidebar: LayoutSidebar {
        return (sidebarTabViewItem.viewController as! NSTabViewController).tabViewItems[0].viewController as! LayoutSidebar
    }
    
    /// Convenient access to the layout storyboard
    internal var _storyboard: NSStoryboard {
        return NSStoryboard(name: "Layout", bundle: nil)
    }
    
    
    // //////////////////////
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sidebarTabViewItem.minimumThickness = 252
        sidebarTabViewItem.maximumThickness = 252
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        setToEditionConfiguration()
        
        _canvas.layout = (window.document as! LayoutDocument).layout
        _canvas.delegate = self
    }
    
    
    // ///////////////////////////////
    // MARK: - Calibration Profile
    
    func setCalibrationProfile(_ sender: NSPopUpButton) {
        // Ignore if its the first element
        if sender.indexOfSelectedItem == 0 { return }
        
        guard sender.indexOfSelectedItem + 1 == sender.itemArray.count else {
            // The user selected an existing profile, let's open it
            _calibrationDocument = layoutDocument.openCalibrationProfile(named: sender.titleOfSelectedItem!)
            return
        }
        
        // Asks the user to name the new profile
        let sheet = self.storyboard!.instantiateController(withIdentifier: "newCalibrationProfileSheet") as! NewCalibrationProfilePanel
        sheet.reference = self
        
        self.presentAsSheet(sheet)
    }
    
    func createCalibrationProfile(named name: String) {
        _calibrationDocument = layoutDocument.makeCalibrationProfile(withName: name)
        
        // Refresh the list of available profiles
        window.fillCalibrationProfilesList()
        
        // And select the newly created profile
        window.selectCalibrationProfile(withName: name)
    }
    
    
    // ///////////////////////////////
    // MARK: - Configuration switching
    
    /// Set the layout window configuration to Edition
    func setToEditionConfiguration() {
        
        _sidebarTabViewController.selectedTabViewItemIndex = 0
        
        _sidebar.canvas = _canvas
        _canvas.editable = true
    }
    
    /// Set the layout window configuration to Calibration
    func setToCalibrationConfiguration() {
        
        _sidebarTabViewController.selectedTabViewItemIndex = 1
        
        _sidebar.canvas = _canvas
        let sidebar = _sidebarTabViewController.tabViewItems[1].viewController as! LayoutSidebarCalibration
        sidebar.calibrationDocument = calibrationDocument
        sidebar.layout = layoutDocument.layout
        
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
