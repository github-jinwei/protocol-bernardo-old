//
//  MainViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class MainViewController: NSTabViewController {
	enum Views: String {
//		case Devices
		case layout
	}

	weak var document: LayoutDocument! {
		didSet {
			layoutView?.document = document
		}
	}

	private var currentView: Views = .layout
	private var currentTabItem: NSTabViewItem!

	override func viewDidLoad() {
		super.viewDidLoad()

		let layoutController: LayoutViewController! = NSNib.make(fromNib: "Layout", owner: nil)
		currentTabItem = NSTabViewItem(viewController: layoutController)
		self.addTabViewItem(currentTabItem)
	}
}

// MARK: - Accessors / Shortcut
extension MainViewController {
	var layoutView: LayoutViewController? {
		guard currentView == .layout else {
			return nil
		}

		return currentTabItem.viewController as? LayoutViewController
	}
}

// MARK: - Calibration Profile
extension MainViewController {
	func openCalibrationProfilePanel() {
		
	}
}
