//
//  DevicesLayout.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Layout: Codable {    
    /// All the elements composing the layout
    var devices = [Device]()
}


// /////////////////////////////
// MARK: - Actions on the layout
extension Layout {
    func createDevice() -> Device {
        let device = Device()
        devices.append(device)
        
        return device
    }
    
    func remove(device: Device) {
        devices.removeAll {
            $0 === device
        }
    }
}
