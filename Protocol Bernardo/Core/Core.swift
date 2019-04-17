//
//  Core.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// The application structure Core
class Core {
	private weak var homeWindow: NSWindowController?

	func registerHomeWindow(_ window: NSWindowController) {
		homeWindow = window
	}

	/// Display the welcome window
	func showHomeWindow() {
		if homeWindow == nil {
			homeWindow = NSStoryboard(name: "Home", bundle: nil).instantiateInitialController() as? NSWindowController
		}

		homeWindow?.showWindow(nil)
	}

	func hideHomeWindow() {
		homeWindow?.close()
	}


	private weak var logsWindow: NSWindowController?

	func registerLogsWindow(_ window: NSWindowController) {
		logsWindow = window
	}

	/// Display the welcome window
	func showLogsWindow() {
		if logsWindow == nil {
			logsWindow = NSStoryboard(name: "Logs", bundle: nil).instantiateInitialController() as? NSWindowController
		}

		logsWindow?.showWindow(nil)
	}

	func hideLogsWindow() {
		logsWindow?.close()
	}
}
