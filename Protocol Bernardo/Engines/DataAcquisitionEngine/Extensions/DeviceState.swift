//
//  DeviceState.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-16.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Current state of a device
extension DeviceState {
    /// English label for the current value
    var label: String {
        switch self {
        case DEVICE_UNKNOWN:    return "-"
        case DEVICE_IDLE:       return "Idle"
        case DEVICE_CONNECTING: return "Connecting"
        case DEVICE_READY:      return "Ready"
        case DEVICE_ACTIVE:     return "Active"
        case DEVICE_CLOSING:    return "Closing"
        default: /** ERROR */   return "Errored"
        }
    }
}

