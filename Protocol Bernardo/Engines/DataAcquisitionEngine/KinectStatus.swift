//
//  KinectStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension KinectStatus {
    /// Returns the kinect serial in as a swift string
    var serial: String {
        get {
            var temp = _serial
            return withUnsafePointer(to: &temp) {
                $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: _serial)) {
                    String(cString: $0)
                }
            }
        }
    }
}
