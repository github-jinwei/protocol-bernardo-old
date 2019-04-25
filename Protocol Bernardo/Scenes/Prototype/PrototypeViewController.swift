//
//  PrototypeViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-25.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PrototypeViewController: NSViewController {
	@IBOutlet weak var chaosRateLabel: NSTextField!
	@IBOutlet weak var sortLevelLabel: NSTextField!
	@IBOutlet weak var sortNumberLabel: NSTextField!

	private var paClass = PrototypeAlpha()

	override func viewDidLoad() {
		super.viewDidLoad()

		paClass.view = self
	}

	override func viewDidAppear() {
		App.core.registerProtoWindow(self.view.window!.windowController!)
			self.view.window?.isMovableByWindowBackground = true
	}

	func update(chaosRate: Double, sortLevel: Double, folder: Int) {
		DispatchQueue.main.async {
			self.chaosRateLabel.doubleValue = chaosRate
			self.sortLevelLabel.doubleValue = sortLevel
			self.sortNumberLabel.integerValue = folder
		}
	}
}
