//
//  MainWindowController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-03.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class MainWindowController: NSWindowController {
	override var document: AnyObject? {
		didSet {
			let layoutDocument = document as? LayoutDocument

			// Propagate references to and from the document
			mainController.document = layoutDocument
			layoutDocument?.layoutView = mainController.layoutView
			sidebarController.document = layoutDocument
		}
	}

	override func windowDidLoad() {
		App.core.hideHomeWindow()
	}
}

// MARK: - Content accessors / shortcuts
extension MainWindowController {
	/// The split view controller
	var splitView: NSSplitViewController! {
		return contentViewController as? NSSplitViewController
	}

	var sidebarController: SidebarController! {
		return splitView.splitViewItems[0].viewController as? SidebarController
	}

	var mainController: MainViewController! {
		return splitView.splitViewItems[1].viewController as? MainViewController
	}
}
