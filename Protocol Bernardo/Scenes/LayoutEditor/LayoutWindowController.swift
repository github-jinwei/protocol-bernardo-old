//
//  LayoutWindowController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutWindowController: NSWindowController {
    
    @IBOutlet weak var windowTitle: NSTextField!
    
    override func windowDidLoad() {
        (contentViewController as! LayoutEditorSplitViewController).window = self
    }
    
    override func windowTitle(forDocumentDisplayName displayName: String) -> String {
        return _layoutDocument.displayName
    }
    
    override var document: AnyObject? {
        didSet {
            if document == nil { return }
            (contentViewController as! LayoutEditorSplitViewController).setLayout(_layoutDocument.layout)
        }
    }
    
    var _layoutDocument: LayoutDocument {
        return self.document as! LayoutDocument
    }
    
    // ///////////////////////
    // MARK: - Toolbar Actions
    
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
