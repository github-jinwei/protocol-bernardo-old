//
//  CGPoint.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-06.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

extension CGPoint {
    init(_ point: Point) {
        self.init()
        self.x = CGFloat(point.x)
        self.y = CGFloat(point.y)
    }
}
