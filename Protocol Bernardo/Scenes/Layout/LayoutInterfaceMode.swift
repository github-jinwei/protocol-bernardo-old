//
//  LayoutInterfaceMode.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

enum LayoutInterfaceMode: Int {
    case edition
    case calibration
    case tracking

    var label: String {
        switch self {
        case .edition: return "edition"
        case .calibration: return "calibration"
        case .tracking: return "tracking"
        }
    }
}
