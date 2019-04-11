//
//  NewCalibrationProfileController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-08.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class NewCalibrationProfileController: NSViewController {

	var createProfileDelegate: ((_ :String) -> Void)?

	@IBOutlet weak var profileNameField: NSTextField!

	@IBAction func createProfile(_: Any) {
		guard profileNameField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " ")).count > 3 else { return }

		createProfileDelegate?(profileNameField.stringValue.trimmingCharacters(in: CharacterSet(charactersIn: " ")))
		dismiss(self)
	}
}
