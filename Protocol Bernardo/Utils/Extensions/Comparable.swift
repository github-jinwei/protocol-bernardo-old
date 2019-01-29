//
//  Comparable.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-29.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self {
        let min = r.lowerBound, max = r.upperBound
        return self < min ? min : (max < self ? max : self)
    }
}
