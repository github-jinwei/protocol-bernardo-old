//
//  LayoutWindowController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// Entry point for the layout interfaces
class LayoutWindowController: NSWindowController {
    
    /// The label used to display the window title.
    ///
    /// Assignement and update of its value is done automatically
    /// using a binding in the storyboard
    @IBOutlet weak var windowTitle: NSTextField!

    /// The segmented controls used by the user to change the layout interface
    @IBOutlet weak var layoutInterfaceButtons: NSSegmentedControl!

    /// The list of calibrated profiles
    @IBOutlet weak var calibrationProfilesList: NSPopUpButton!
        
    /// The Layout Window delegate
    weak var delegate: LayoutWindowDelegate?
    
    /// The document holding this window, and the one the window is representing
    override var document: AnyObject? {
        didSet {
            guard document != nil else { return }

            fillCalibrationProfilesList()
        }
    }
    


    // /////////////////////////
    // MARK: - Convenient access
    
    /// Convenient access to the window content controller
    internal var layoutController: LayoutController {
        return contentViewController as! LayoutController
    }
    
    /// The window document in the proper format
    var layoutDocument: LayoutDocument {
        return self.document as! LayoutDocument
    }



    // //////////////////////
    // MARK: - View Lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()

        // Mark ourselves as the window delegate
        window?.delegate = self

        layoutController.window = self
    }
    
    // ///////////////
    // MARK: - Toolbar
    
    /// Changes the Layout interface the desired configuration
    ///
    /// - Parameter sender:
    @IBAction func switchInterface(_ sender: NSSegmentedControl) {
        let interfaceType: LayoutInterfaceMode
        switch sender.selectedSegment {
        case 0: interfaceType = .edition
        case 1: interfaceType = .calibration
        case 2: interfaceType = .tracking
        default: return
        }

        delegate?.toolbar(self, interfaceModeHasChanged: interfaceType)
    }

    /// Open or Close the sidebar
    ///
    /// - Parameter sender: The toggle sidebar button
    @IBAction func toggleSidebar(_ sender: Any) {
        layoutController.toggleSidebar(sender)
    }
}



// ///////////////////////////////////
// MARK: - Calibration profile methods
extension LayoutWindowController {
    /// Fill the list of available calibration profiles
    internal func fillCalibrationProfilesList() {
        var profiles: [String] = ["No Profile"]

        for (profileName, _) in layoutDocument.calibrationsProfiles {
            profiles.append(profileName)
        }
        
        profiles.append("+ New Profile")

        calibrationProfilesList.removeAllItems()
        calibrationProfilesList.addItems(withTitles: profiles)

        calibrationProfilesList.itemArray.first!.isEnabled = false
    }

    /// Create a new calibration profile and select it
    ///
    /// - Parameter name: Name of the calibration profile to create
    func createCalibrationProfile(_ name: String) -> Void {
        _ = layoutDocument.makeCalibrationProfile(withName: name)

        // Refresh the list of available profiles
        fillCalibrationProfilesList()

        // And select the newly created profile
        calibrationProfilesList.selectItem(withTitle: name)
        setCalibrationProfile(calibrationProfilesList)
    }

    /// Called when the user selects a calibration profile on the toolbar list
    ///
    /// Takes care of displaying a sheet to ask for a profile name if the user
    /// wants to create a new profile
    ///
    /// - Parameter sender: _
    @IBAction func setCalibrationProfile(_ sender: NSPopUpButton) {
        if calibrationProfilesList.indexOfSelectedItem == 0 {
            // User selected "No Profile"
            delegate?.toolbar(self, calibrationProfileChanged: nil)
            return
        }

        if calibrationProfilesList.indexOfSelectedItem + 1 == calibrationProfilesList.itemArray.count {
            // User wants to create a new calibration profile
            // Asks the user to name the new profile
            let sheet = storyboard!.instantiateController(withIdentifier: "newCalibrationProfileSheet") as! NewCalibrationProfilePanel
            sheet.createProfileDelegate = createCalibrationProfile

            contentViewController!.presentAsSheet(sheet)
            return
        }

        // User selected an existing profile
        let calibrationProfile = layoutDocument.calibrationsProfiles[sender.titleOfSelectedItem!]

        // Tell the delegate
        delegate?.toolbar(self, calibrationProfileChanged: calibrationProfile)
    }
}



// /////////////////////////
// MARK: - NSWindowDelegate
extension LayoutWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        layoutDocument.save(nil)
        layoutDocument.canClose(withDelegate: self,
                                shouldClose: #selector(document(doc:shouldClose:contextInfo:)),
                                contextInfo: nil)



        return false
    }
}



// ////////////////////////////
// MARK: - NSDocumentDelegate
extension LayoutWindowController {

    @objc
    func document(doc: NSDocument, shouldClose: Bool, contextInfo: UnsafeRawPointer?) {
        if shouldClose {
            self.close()
        }
    }
}
