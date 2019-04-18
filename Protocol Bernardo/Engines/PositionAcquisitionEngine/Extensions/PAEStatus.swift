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
		return String.fromCString(hostname)
	}
}
