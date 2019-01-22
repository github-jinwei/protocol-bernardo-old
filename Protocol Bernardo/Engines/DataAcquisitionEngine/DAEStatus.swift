//
//  DAEStatus.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension DAEStatus {
    /// List of all the kinects in a Swift friendly format
    var kinects: [String: KinectStatus] {
        get {
            // The map
            var kinectsMap = [String: KinectStatus]()

            // Pointer used for parsing
            var pointer = _kinectStatus
            
            // Loop on each kinect
            for i in 0..<kinectCount {
                let kinectStatus = pointer!.pointee
                
                // Insert in the map
                kinectsMap[kinectStatus.serial] = kinectStatus
                
                // Check if we can advance
                if i + 1 < kinectCount {
                    pointer = pointer?.successor()
                }
            }
            
            return kinectsMap
        }
    }
}
