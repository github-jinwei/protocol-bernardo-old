//
//  AcquisitionMachine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// An acquisition machine represent a computer connected to one or more physical device.
struct AcquisitionMachine {
	var name: String

	var devices: [Serial: AcquisitionDevice]
}

extension AcquisitionMachine {
	/// Return the connected device with the matching serial
	///
	/// Returns nil if there is no matching device
	///
	/// - Parameter serial: A physical device serial
	/// - Returns: A physical device
	func device(withSerial serial: Serial?) -> AcquisitionDevice? {
		if serial == nil {
			return nil
		}

		return devices.first(where: { $0.key == serial })?.value
	}
}
