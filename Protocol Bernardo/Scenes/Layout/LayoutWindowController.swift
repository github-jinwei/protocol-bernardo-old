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
    
    internal var _waitingToQuit: Bool = false
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        
            _controller.window = self
    }
    
    /// The document holding this window, and the one the window is representing
    override var document: AnyObject? {
        didSet {
            if document == nil { return }
            
            layoutDocument.delegate = self
            
            fillCalibrationProfilesList()
        }
    }
    
    
    // /////////////////////////
    // MARK: - Convenient access
    
    internal var _controller: LayoutSplitViewController {
        return contentViewController as! LayoutSplitViewController
    }
    
    /// The window document in the proper format
    var layoutDocument: LayoutDocument {
        return self.document as! LayoutDocument
    }
    
    
    // ///////////////
    // MARK: - Toolbar
    
    /// Changes the Layout interface the desired configuration
    ///
    /// - Parameter sender:
    @IBAction func switchInterface(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0: _controller.setToEditionConfiguration()
        case 1: _controller.setToCalibrationConfiguration()
        case 2: _controller.setToCalibrationConfiguration()
        default: break;
        }
    }
    
    @IBOutlet weak var calibrationProfilesList: NSPopUpButton!
    
    internal func fillCalibrationProfilesList() {
        var profiles: [String] = ["No Profile"]
        layoutDocument.calibrationsProfiles.forEach { profiles.append($0.key) }
        profiles.append("+ New Profile")
        
        calibrationProfilesList.removeAllItems()
        calibrationProfilesList.addItems(withTitles: profiles)
        
        calibrationProfilesList.itemArray.first!.isEnabled = false
    }
    
    func selectCalibrationProfile(withName name: String) {
        calibrationProfilesList.selectItem(withTitle: name)
        setCalibrationProfile(calibrationProfilesList)
    }
    
    @IBAction func setCalibrationProfile(_ sender: NSPopUpButton) {
        _controller.setCalibrationProfile(sender)
    }
    
}

extension LayoutWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // If the document hasn't been edited, simply close the window
        guard window!.isDocumentEdited else {
            return true
        }
        
        // Ask the user user if he wants to save and quit, cancel, or discard changes
        let confirmModal = NSAlert()
        confirmModal.alertStyle = .warning
        confirmModal.messageText = "There is unsaved changes. Do you want to save them ?"
        confirmModal.addButton(withTitle: "Save and Quit")
        confirmModal.addButton(withTitle: "Cancel")
        confirmModal.addButton(withTitle: "Discard Changes")
        
        confirmModal.beginSheetModal(for: self.window!) { res in
            if res == NSApplication.ModalResponse.alertSecondButtonReturn {
                // Do nothing on cancel button
                return
            }
            
            if res == .alertFirstButtonReturn {
                self._waitingToQuit = true
                self.layoutDocument.save(withDelegate: self, didSave: #selector(self.document(_:didSave:contextInfo:)), contextInfo: nil)
                return
            }
            
            if res == .alertThirdButtonReturn {
                self.window!.close()
            }
        }

        return false
    }
    
    func windowWillClose(_ notification: Notification) {
        (document as! LayoutDocument).close()
    }
}

// MARK: - NSDocument delegate
extension LayoutWindowController: NSDocumentDelegate {
    @objc
    func document(_ doc: NSDocument, didSave: Bool, contextInfo: UnsafeRawPointer?) {
        if didSave {
            self.window!.isDocumentEdited = false
        }
        
        // Should we close the button ?
        if (_waitingToQuit) {
            self.close()
        }
    }
}
