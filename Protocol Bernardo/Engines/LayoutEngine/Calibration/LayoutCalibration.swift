//
//  LayoutCalibration.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class LayoutCalibration: Codable {
    var name: String
    
    var calibratedDevices: [String: CalibratedDevice] = [:]

    init(name: String) {
        self.name = name
    }
}
