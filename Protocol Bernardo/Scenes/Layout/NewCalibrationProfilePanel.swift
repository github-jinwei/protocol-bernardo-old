//
//  NewCalibrationProfilePanel.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-07.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class NewCalibrationProfilePanel: NSViewController {
    
    var createProfileDelegate: ((_ :String) -> Void)?
    
    @IBOutlet weak var profileNameField: NSTextField!
    
    @IBAction func cancelButton(_: Any) {
        dismiss(self)
    }
    
    @IBAction func createButton(_: Any) {
        guard profileNameField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " ")).count > 3 else { return }

        createProfileDelegate?(profileNameField.stringValue)
        dismiss(self)
    }
}
