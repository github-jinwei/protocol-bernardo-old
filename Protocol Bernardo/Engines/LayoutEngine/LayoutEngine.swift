//
//  LayoutEngine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutEngine {
    func newLayout() -> Layout {
        return Layout()
    }
    
    func openLayout(at url: URL) -> Layout? {
        try! LayoutDocument(contentsOf: url, ofType: "pb.layout")
        return nil
    }
}
