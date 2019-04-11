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
}
