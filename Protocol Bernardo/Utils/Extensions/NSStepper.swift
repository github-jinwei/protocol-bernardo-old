//
//  NSStepper.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-31.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

extension NSStepper {
    func setBehavior(minValue: Double, maxValue: Double, increment: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.increment = increment
    }
}
