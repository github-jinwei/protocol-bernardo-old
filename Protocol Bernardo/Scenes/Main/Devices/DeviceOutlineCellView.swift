//
//  DeviceOutlineCellView.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class DeviceOutlineCellView: NSTableCellView {
	var serial: Serial! {
		didSet {
			// Update the serial label
			deviceSerialLabel.stringValue = serial
		}
	}

	// OUTLETS

	@IBOutlet weak var deviceNameLabel: NSTextField!
	@IBOutlet weak var deviceSerialLabel: NSTextField!
	@IBOutlet weak var deviceStatusLabel: NSTextField!
	@IBOutlet weak var actionButton: NSButton!
	@IBOutlet weak var usersCountLabel: NSTextField!
	@IBOutlet weak var trackedCountLabel: NSTextField!

	@IBAction func toggleDeviceState(_: AnyObject) {
		App.pae.toggleDeviceStatus(withSerial: serial)
	}

	func update(status: AcquisitionDevice) {
		DispatchQueue.main.async {

			// Update the state label
			self.deviceStatusLabel.stringValue = status.state.label

			var actionButtonState = false
			var actionButtonTitle = "..."

			// Update the action button label
			switch status.state {
			case DEVICE_IDLE: // Connecting
				actionButtonState = true
				actionButtonTitle = "Connect"
			case DEVICE_CONNECTING: // Connecting
				actionButtonState = false
			case DEVICE_READY: // Ready
				actionButtonState = true
				actionButtonTitle = "Activate"
			case DEVICE_ACTIVE: // Active
				actionButtonState = true
				actionButtonTitle = "Pause"
			case DEVICE_CLOSING: // Closing
				actionButtonState = false
			default: // Errored
				actionButtonState = false
				actionButtonTitle = "Errored"
			}

			self.actionButton.isEnabled = actionButtonState
			self.actionButton.title = actionButtonTitle

			self.usersCountLabel.integerValue = status.users.count
			self.trackedCountLabel.integerValue = status.trackedUsers.count
		}
	}
}
