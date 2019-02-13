//
//  ConnectedDevices.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-12.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class ConnectedDevices {
    internal var _devices: [Serial: PhysicalDevice] = [:]
    
    var devices: [Serial: PhysicalDevice] {
        get {
            return _devices
        }
    }
    
    func setDevices(_ devices: [Serial: PhysicalDevice]) {
        _devices = devices
    }
}

extension ConnectedDevices {
    func with(serial: Serial?) -> PhysicalDevice? {
        if serial == nil { return nil }
        
        return _devices.first(where: { $0.key == serial })?.value
    }
    
    var count: Int {
        get {
            return _devices.count
        }
    }
}
