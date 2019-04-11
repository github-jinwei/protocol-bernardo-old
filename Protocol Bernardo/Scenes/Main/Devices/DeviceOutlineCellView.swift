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

	var state: DeviceState! {
		didSet {
			// Update the state label
			deviceStatusLabel.stringValue = state.label

			// Update the action button label
			switch state {
			case DEVICE_IDLE: // Connecting
				actionButton.isEnabled = true
				actionButton.title = "Connect"
			case DEVICE_CONNECTING: // Connecting
				actionButton.isEnabled = false
			case DEVICE_READY: // Ready
				actionButton.isEnabled = true
				actionButton.title = "Activate"
			case DEVICE_ACTIVE: // Active
				actionButton.isEnabled = true
				actionButton.title = "Pause"
			case DEVICE_CLOSING: // Closing
				actionButton.isEnabled = false
			default: // Errored
				actionButton.isEnabled = false
				actionButton.title = "Errored"
			}
		}
	}

	// OUTLETS

	@IBOutlet weak var deviceNameLabel: NSTextField!
	@IBOutlet weak var deviceSerialLabel: NSTextField!
	@IBOutlet weak var deviceStatusLabel: NSTextField!
	@IBOutlet weak var actionButton: NSButton!

	@IBAction func toggleDeviceState(_: AnyObject) {
		App.pae.toggleDeviceStatus(withSerial: serial)
	}
}
