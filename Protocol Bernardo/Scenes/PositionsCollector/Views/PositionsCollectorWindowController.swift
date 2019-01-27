//
//  PositionsCollectorWindowController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class PositionsCollectorWindowController: NSWindowController {
    
    weak var movementsCollector: PositionsCollector!
    
    override func windowDidLoad() {
        window!.delegate = self
        window!.title = "Positions Collector"
    }
}

// MARK: - NSWindowDelegate
extension PositionsCollectorWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        movementsCollector.endScene()
    }
}
