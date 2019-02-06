//
//  DevicesLayout.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Layout: Codable {    
    /// All the devices composing the layout
    var devices = [Device]()
    
    /// All the lines composing the layout
    var decorations = [Line]()
}


// /////////////////////////////
// MARK: - Actions on the layout
extension Layout {
    func createDevice() -> Device {
        let device = Device()
        devices.append(device)
        
        return device
    }
    
    func createLine() -> Line {
        let line = Line()
        decorations.append(line)
        
        return line
    }
    
    func remove(device: Device) {
        devices.removeAll {
            $0 === device
        }
    }
    
    func remove(line: Line) {
        decorations.removeAll {
            $0 === line
        }
    }
}
