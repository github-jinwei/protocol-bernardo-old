//
//  PBKinectRow.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class PBKinectRow: NSView {
    var serial:String!
    
    @IBOutlet weak var outletBox: NSBox!
    @IBOutlet weak var serialField: NSTextField!
    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var actionButton: NSButton!
    @IBOutlet weak var quickLookButton: NSButton!
    
    @IBAction func toggleState(_ sender: AnyObject) {
        App.dae.toggleKinectStatus(withSerial: serial)
    }
    
    @IBAction func openQuickLook(_ sender: AnyObject) { }
}
