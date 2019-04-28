//
//  PAEStatusCollection.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Represent the current state of the C++ DAE
///
/// You should not use this structure directly as it is converted to `ConnectedDevices` upon
/// receiving.
extension PAEStatusCollection {
    /// List of all the devices in a Swift friendly format
    func copyAndDeallocate() -> [AcquisitionMachine] {
		var machines = [AcquisitionMachine]()

		// Machine parsing pointer
		var machinePointer = status

		for i in 0..<statusCount {

			// Pointer used for parsing
			let paeStatus = machinePointer!.pointee!.pointee

			var machine = AcquisitionMachine(name: paeStatus.machinename, devices: [:])

			var devicePointer = paeStatus.connectedDevices

			// Loop on each device
			for i in 0..<paeStatus.deviceCount {
				let paeDeviceStatus = devicePointer!.pointee

				// Insert in the map
				machine.devices[paeDeviceStatus.serial] = AcquisitionDevice(from: paeDeviceStatus)

				// Free it
				paeDeviceStatus.trackedUsers.deallocate()

				// Check if we can advance
				if i + 1 < paeStatus.deviceCount {
					devicePointer = devicePointer?.successor()
				}
			}

			machines.append(machine)

			// Free the array
			devicePointer?.deallocate()
			machinePointer!.pointee!.deallocate();

			if i + 1 < statusCount {
				machinePointer = machinePointer?.successor()
			}
		}

		status.deallocate()

        return machines
    }
}
