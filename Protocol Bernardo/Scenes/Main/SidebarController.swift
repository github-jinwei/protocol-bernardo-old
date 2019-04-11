//
//  SidebarController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import AppKit

class SidebarController: NSViewController {

	@IBOutlet weak var topConstraint: NSLayoutConstraint!

	// Reference to the document
	weak var document: LayoutDocument! {
		didSet {
			// Assign the document to all the needing sidebars
			for viewItem in sidebarTabView.tabViewItems {
				(viewItem.viewController as? DocumentHandlerSidebar)?.document = document
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Watch window fullscreen to adjust interface
		NotificationCenter.default.addObserver(self, selector: #selector(onEnterFullscreen), name: NSWindow.didEnterFullScreenNotification, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onExitFullscreen), name: NSWindow.didExitFullScreenNotification, object: nil)

		// Load sidebars
		let devicesController: DevicesSidebarController = NSNib.make(fromNib: "Devices", owner: nil)
		let devicesTabItem = NSTabViewItem(viewController: devicesController)

		let layoutController: EditionSidebarController = NSNib.make(fromNib: "Layout", owner: nil)
		let layoutTabItem = NSTabViewItem(viewController: layoutController)

		let calibrationController: CalibrationSidebarController = NSNib.make(fromNib: "Calibration", owner: nil)
		let calibrationTabItem = NSTabViewItem(viewController: calibrationController)

		let trackingController: TrackingSidebarController = NSNib.make(fromNib: "Tracking", owner: nil)
		let trackingTabItem = NSTabViewItem(viewController: trackingController)

		sidebarTabView.addTabViewItem(devicesTabItem)
		sidebarTabView.addTabViewItem(layoutTabItem)
		sidebarTabView.addTabViewItem(calibrationTabItem)
		sidebarTabView.addTabViewItem(trackingTabItem)

		setSidebar(to: .devices)
	}

	public enum Types: Int {
		case devices = 0
		case edit = 1
		case calibrate = 2
		case track = 3
		case display = 4
	}

	// MARK: - Sidebar

	@IBOutlet weak var sidebarTabView: NSTabView!

	// MARK: Tab bar

	let offColor = NSColor.secondaryLabelColor
	let onColor = NSColor.controlAccentColor

	@IBOutlet weak var devicesSidebarButton: NSButton!
	@IBOutlet weak var editSidebarButton: NSButton!
	@IBOutlet weak var calibrateSidebarButton: NSButton!
	@IBOutlet weak var trackSidebarButton: NSButton!
	@IBOutlet weak var displaySidebarButton: NSButton!

	@IBAction func openDevicesSidebar(_ sender: Any) {
		setSidebar(to: .devices)
	}

	@IBAction func openEditSidebar(_ sender: Any) {
		setSidebar(to: .edit)
	}

	@IBAction func openCalibrateSidebar(_ sender: Any) {
		setSidebar(to: .calibrate)
	}

	@IBAction func openTrackSidebar(_ sender: Any) {
		setSidebar(to: .track)
	}

	@IBAction func openDisplaySidebar(_ sender: Any) {
		setSidebar(to: .display)
	}

	func setSidebar(to sidebarType: SidebarController.Types) {
		// Update all the interface buttons
		// Devices sidebar
		devicesSidebarButton.image = NSImage(named: sidebarType == .devices ? "devices-selected" : "devices-idle")
		devicesSidebarButton.contentTintColor = sidebarType == .devices ? onColor : offColor

		// Edit sidebar
		editSidebarButton.image = NSImage(named: sidebarType == .edit ? "edit-selected" : "edit-idle")
		editSidebarButton.contentTintColor = sidebarType == .edit ? onColor : offColor

		// Calibrate sidebar
		calibrateSidebarButton.image = NSImage(named: sidebarType == .calibrate ? "calibrate-selected" : "calibrate-idle")
		calibrateSidebarButton.contentTintColor = sidebarType == .calibrate ? onColor : offColor

		// Track sidebar
		trackSidebarButton.image = NSImage(named: sidebarType == .track ? "track-selected" : "track-idle")
		trackSidebarButton.contentTintColor = sidebarType == .track ? onColor : offColor

		// Display sidebar
		displaySidebarButton.image = NSImage(named: sidebarType == .display ? "display-selected" : "display-idle")
		displaySidebarButton.contentTintColor = sidebarType == .display ? onColor : offColor

		sidebarTabView.selectTabViewItem(at: sidebarType.rawValue)
	}
}

extension SidebarController {
	@objc func onEnterFullscreen(_: NSNotification) {
		topConstraint.constant = 5
	}


	@objc func onExitFullscreen(_: NSNotification) {
		topConstraint.constant = 25
	}
}
