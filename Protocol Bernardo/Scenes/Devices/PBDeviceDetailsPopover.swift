//
//  PBDeviceDetailsPopover.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-26.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBDeviceDetailsPopover: NSPopover {
    /// Convenient access to get the controller in the proper type
    var controller: PBDeviceDetails {
        get {
            return contentViewController as! PBDeviceDetails
        }
    }
}
