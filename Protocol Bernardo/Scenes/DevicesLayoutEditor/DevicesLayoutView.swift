//
//  DevicesLayoutView.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-29.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

class DevicesLayoutView: SKView {
    var editor: LayoutEditor!
    
    override func mouseDown(with event: NSEvent) {
        editor?.mouseDown(with: event)
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        editor?.mouseUp(with: event)
        super.mouseUp(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        editor?.mouseDragged(with: event)
        super.mouseDragged(with: event)
    }
    
    override func scrollWheel(with event: NSEvent) {
        editor?.scrollWheel(with: event)
        super.scrollWheel(with: event)
    }
    
    override func magnify(with event: NSEvent) {
        editor?.magnify(with: event)
        super.magnify(with: event)
    }
}
