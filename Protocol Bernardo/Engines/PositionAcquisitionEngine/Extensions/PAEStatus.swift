//
//  PAEStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension PAEStatus {
	/// The host's name
	var machinename: String {
		var temp = hostname
		return withUnsafePointer(to: &temp) {
			$0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: hostname)) {
				String(cString: $0)
			}
		}
	}
}
