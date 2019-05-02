//
//  DevicesSidebarController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class DevicesSidebarController: NSViewController, DocumentHandlerSidebar {
	/// Reference to the document
	weak var document: LayoutDocument! {
		didSet {
			guard document != nil else { return }
			
			// Fill the fields
			serverIPField.stringValue = document.layout.serverIP ?? "255.255.255.255"
			serverPortField.stringValue = document.layout.serverPort ?? "0000"
		}
	}

	override func viewDidLoad() {
		devicesList.dataSource = self
		devicesList.delegate = self

		App.pae.addObserver(self)
		App.pae.start()
	}

	deinit {
		App.pae.removeObserver(self)
	}

	/// Activate or deactivate devices liveview
	///
	/// - Parameter sender: _
	@IBAction func toggleLiveView(_ sender: Any) {
		App.pae.toggleLiveView()
	}

	/// The onscreen list of devices (local and remote)
	@IBOutlet weak var devicesList: NSOutlineView!

	// MARK: - Network

	/// True if this machine is a master or a slave
	private var isMaster = true

	/// The relay server IP field
	@IBOutlet weak var serverIPField: NSTextField!

	/// The server port field
	@IBOutlet weak var serverPortField: NSTextField!

	/// The link status field
	@IBOutlet weak var linkStatusButton: NSButton!

	/// Switch the machine status to master or slave
	///
	/// - Parameter sender: _
	@IBAction func toggleMasterSlave(_ sender: Any) {
		if isMaster {
			// Switch to slave
			PAEShouldReceive(0)
			PAEShouldEmit(1)
			isMaster = false
			return
		}

		// Switch to master
		PAEShouldReceive(1)
		PAEShouldEmit(0)
		isMaster = true
	}

	/// Tries to connect to the server using the inputted IP and Port
	///
	/// - Parameter sender: <#sender description#>
	@IBAction func connectToServer(_ sender: Any) {
		// TODO: Validate the values before assigning
		document.layout.serverIP = serverIPField.stringValue
		document.layout.serverPort = serverPortField.stringValue
		document.markAsEdited()

		PAEConnectTo(document.layout.serverIP, document.layout.serverPort, 0)
	}

	var machines = [AcquisitionMachine]()


	var machinesCellView = [String: MachineOutlineCellView]()
	var devicesCellView = [Serial: DeviceOutlineCellView]()
}

extension DevicesSidebarController: PositionAcquisitionEngineObserver {
	func pae(_ pae: PositionAcquisitionEngine, statusUpdated updatedMachines: [AcquisitionMachine]) {
		machines = updatedMachines

		// Update sidebar views
		for machine in self.machines {
			if machinesCellView[machine.name] == nil {
				DispatchQueue.main.async { self.devicesList.reloadData() }
				break
			}

			for device in machine.devices {
				if let deviceView = devicesCellView[device.value.serial] {
					deviceView.update(status: device.value)
					continue
				}

				DispatchQueue.main.async {
					self.devicesList.reloadItem(machine, reloadChildren: true)
				}
				break
			}
		}

		let imageName = PAELinkIsConnected() == 1 ? "NSStatusAvailable" : "NSStatusUnavailable"

		DispatchQueue.main.async {
			self.linkStatusButton.image = NSImage(named: imageName)
		}
		
	}
}

extension DevicesSidebarController: NSOutlineViewDataSource {
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return machines.count
		}

		if let machine = item as? AcquisitionMachine {
			return machine.devices.count
		}

		return 0
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let machine = item as? AcquisitionMachine {
			return machine.devices.count >= 1
		}

		return false
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let machine = item as? AcquisitionMachine {
			return machine.devices.sorted(by: { $0.key < $1.key })[index].value
		}

		return machines[index]
	}

	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		if item is AcquisitionMachine {
			return 14
		}

		return 64
	}

	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return item is AcquisitionDevice
	}
}

extension DevicesSidebarController: NSOutlineViewDelegate {
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if let machine = item as? AcquisitionMachine {
			if let cell = machinesCellView[machine.name] {
				// The cell already exist
				return cell
			}

			// Create the cell
			let machineCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "machineCell"), owner: self) as! MachineOutlineCellView
			machineCell.machineNameField.stringValue = machine.name

			machinesCellView[machine.name] = machineCell

			return machineCell
		}

		if let device = item as? AcquisitionDevice {
			if let cell = devicesCellView[device.serial] {
				// The cell already exist
				return cell
			}

			let deviceCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deviceCell"), owner: self) as! DeviceOutlineCellView
			deviceCell.serial = device.serial
			deviceCell.deviceNameLabel.stringValue = device.name
			deviceCell.deviceStatusLabel.stringValue = device.state.label

			devicesCellView[device.serial] = deviceCell

			return deviceCell
		}

		return nil
	}
}
