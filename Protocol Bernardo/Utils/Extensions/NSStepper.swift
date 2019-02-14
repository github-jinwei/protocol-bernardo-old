//
//  NSStepper.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-31.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

extension NSStepper {
    /// Convenient method to set the min, max and increment value of the stepper
    ///
    /// - Parameters:
    ///   - minValue: The stepper's minimum value
    ///   - maxValue: The stepper's maximum value
    ///   - increment: The stepper's increment value
    func setBehavior(minValue: Double, maxValue: Double, increment: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.increment = increment
    }
}
