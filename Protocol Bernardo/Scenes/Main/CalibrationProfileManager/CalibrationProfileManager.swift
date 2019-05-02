//
//  CalibrationProfileManager.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-07.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class CalibrationProfileManager: NSViewController {

	weak var document: LayoutDocument!

	@IBOutlet weak var profilesList: NSTableView!

	@IBOutlet weak var removeProfileButton: NSButton!

	@IBOutlet weak var openProfileButton: NSButton!
}

// MARK: - Unified opening
extension CalibrationProfileManager {

	static func open(fromController parentController: NSViewController, withLayout document: LayoutDocument) {
		let profilesController:CalibrationProfileManager = NSNib.make(fromNib: "CalibrationProfileManager", owner: nil)
		profilesController.document = document

		parentController.presentAsSheet(profilesController)
	}
}

// MARK: - Actions
extension CalibrationProfileManager {
	@IBAction func openMakeProfilePanel(_ sender: Any?) {
		let makeProfilePanel: NewCalibrationProfileController = NSNib.make(fromNib: "CalibrationProfileManager", owner: nil)
		makeProfilePanel.createProfileDelegate = createCalibrationProfile
		presentAsSheet(makeProfilePanel)
	}

	/// Create a new calibration profile and select it
	///
	/// - Parameter name: Name of the calibration profile to create
	func createCalibrationProfile(_ name: String) {
		_ = document.makeCalibrationProfile(withName: name)

		// Refresh the list of available profiles
		profilesList.reloadData()
	}

	@IBAction func removeProfile(_ sender: Any?) {
		guard profilesList.selectedRow > -1 else {
			return
		}

		let selectedProfile = document.calibrationsProfiles.sorted(by: { $0.key < $1.key })[profilesList.selectedRow]

		document.removeCalibrationProfile(withName: selectedProfile.key)
	}

	@IBAction func openProfile(_ sender: Any?) {
		guard profilesList.selectedRow > -1 else {
			return
		}

		let selectedProfile = document.calibrationsProfiles.sorted(by: { $0.key < $1.key })[profilesList.selectedRow]

		document.set(calibrationProfile: selectedProfile.key)

		dismiss(self)
	}
}

// MARK: - NSTableViewDataSource
extension CalibrationProfileManager: NSTableViewDataSource {
	func numberOfRows(in tableView: NSTableView) -> Int {
		return document.calibrationsProfiles.count
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return document.calibrationsProfiles.sorted(by: { $0.key < $1.key })[row].value
	}
}

// MARK: - NSTableViewDelegate
extension CalibrationProfileManager: NSTableViewDelegate {
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cell = profilesList.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "profileCell"), owner: self) as! NSTableCellView
		cell.textField?.stringValue = document.calibrationsProfiles.sorted(by: { $0.key < $1.key })[row].key

		return cell
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		openProfileButton.isEnabled = profilesList.selectedRow > -1
		removeProfileButton.isEnabled = profilesList.selectedRow > -1
	}
}
