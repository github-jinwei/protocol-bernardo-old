//
//  DevicesLayout.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Layout: Codable {
    /// Name of the layout
    var layoutName: String = "Layout" {
        didSet { modified = true }
    }
    
    /// Where the layout is saved on the user file system
    ///
    /// A nil value means the layout is new and has never been saved
    var layoutSavePath: String? = nil
    
    /// Tell if the layout has beem modified since its last save or creation
    var modified: Bool = false
    
    /// All the elements composing the layout
    var elements = [LayoutElement]() {
        didSet { modified = true }
    }
}


// /////////////////////////////
// MARK: - Actions on the layout
extension Layout {
    func createDevice() -> Device {
        let device = Device()
        elements.append(device)
        
        return device
    }
    
    func removeElement(_ element: LayoutElement) {
        elements.removeAll {
            $0 === element
        }
    }
}
