//
//  MovementsCollectorWindowController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class MovementsCollectorWindowController: NSWindowController {
    
    weak var movementsCollector: MovementsCollector!
    
    override func windowDidLoad() {
        window!.delegate = self
        window!.title = "Movements Collector"
    }
}

// MARK: - NSWindowDelegate
extension MovementsCollectorWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        movementsCollector.endScene()
    }
}
