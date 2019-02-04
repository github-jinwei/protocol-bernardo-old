//
//  Device.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

class Device: LayoutElement {
    var horizontalFOV: CGFloat = 70.0
    
    var minimumCaptationDistance: CGFloat = 50.0
    
    var maximumCaptationDistance: CGFloat = 450.0
    
    var position = CGPoint(x: 0, y: 0)
    
    var orientation: CGFloat = 0.0
    
    var height: CGFloat = 60.0
}
