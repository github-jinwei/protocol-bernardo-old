//
//  LogsViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-17.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LogsViewController: NSViewController {
	@IBOutlet weak var textField: NSTextView!

	override func viewDidLoad() {
		App.logs = self

		textField.font = NSFont(name: "SFMono-Semibold", size: 12)
	}

	override func viewDidAppear() {
		App.core.registerLogsWindow(self.view.window!.windowController!)
	}

	func insert(message: String, prefix: String? = nil) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

		var line = "[" + dateFormatter.string(from: Date()) + "]"

		if prefix != nil {
			line += " [" + prefix! + "]"
		}

		line += " " + message

		DispatchQueue.main.async {
			let scroll = NSMaxY(self.textField.visibleRect) == NSMaxY(self.textField.bounds)

			self.textField.string += line + "\n"

			if scroll {
				self.textField.scrollToEndOfDocument(self)
			}
		}
	}
}
