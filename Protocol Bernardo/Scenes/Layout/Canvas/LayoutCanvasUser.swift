//
//  LayoutCanvasUser.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

class LayoutCanvasUser: SKShapeNode {
    convenience init(user: User) {
        self.init(circleOfRadius: 10)
        
        let position = user.calibratedPosition
        
        self.position.x = CGFloat(-position.x / 10.0)
        self.position.y = CGFloat(position.z / 10.0)
        
        let color = NSColor.systemPink
        
        self.strokeColor = NSColor(color, alpha: 0.8)
        self.fillColor = NSColor(color, alpha: 0.6)
        
        let numberOfTrackers = SKLabelNode(text: "\(user.trackedPhysics.count)")
        numberOfTrackers.horizontalAlignmentMode = .center
        numberOfTrackers.verticalAlignmentMode = .center
        numberOfTrackers.position.x -= 1
        numberOfTrackers.fontSize = 14
        numberOfTrackers.fontName = NSFont.systemFont(ofSize: 14, weight: .bold).fontName
        self.addChild(numberOfTrackers)
    }
}
