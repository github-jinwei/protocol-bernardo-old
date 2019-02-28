//
//  NewTrackingSessionPanel.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-24.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class NewTrackingSessionPanel: NSViewController {
    var createSessionDelegate:((_: String) -> Void)?

    @IBOutlet weak var sessionNameField: NSTextField!

    @IBAction func cancel(_ sender: NSButton) {
        dismiss(self)
    }

    @IBAction func createSession(_ sender: NSButton) {
        guard sessionNameField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " ")).count > 3 else { return }

        createSessionDelegate?(sessionNameField.stringValue)
        dismiss(self)
    }
}
