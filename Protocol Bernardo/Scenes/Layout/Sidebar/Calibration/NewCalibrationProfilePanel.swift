//
//  NewCalibrationProfilePanel.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-07.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class NewCalibrationProfilePanel: NSViewController {
    
    weak var reference: LayoutSplitViewController?
    
    @IBOutlet weak var profileNameField: NSTextField!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(self)
    }
    
    @IBAction func createButton(_ sender: Any) {
        guard profileNameField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " ")).count > 3 else { return }
        reference?.createCalibrationProfile(named: profileNameField.stringValue)
        dismiss(self)
    }
}
