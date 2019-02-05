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
        window?.delegate = self
        
        (contentViewController as! LayoutSplitViewController).window = self
    }
    
    /// The document holding this window, and the one the window is representing
    override var document: AnyObject? {
        didSet {
            if document == nil { return }
            _layoutDocument.delegate = self
            (contentViewController as! LayoutSplitViewController).setLayout(_layoutDocument.layout)
        }
    }
    
    /// The window document in the proper format
    var _layoutDocument: LayoutDocument {
        return self.document as! LayoutDocument
    }
    
    // ///////////////////////
    // MARK: - Toolbar Actions
    
    /// Changes the Layout interface the desired configuration
    ///
    /// - Parameter sender:
    @IBAction func switchInterface(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 1:
            // Set up for edition
            print("Switching to Edition")
            return
        case 2:
            // Set up for calibration
            print("Switching to Calibration")
            return
        case 3:
            // Set up for tracking
            print("Switching to Tracking")
            return
        default: break;
        }
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
                self._layoutDocument.save(withDelegate: self, didSave: #selector(self.document(_:didSave:contextInfo:)), contextInfo: nil)
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
