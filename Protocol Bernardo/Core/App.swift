//
//  App.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

struct App {
    /// The application core, handling the scenes
    static let core = Core()
    
    /// The Data Acquisition Engine
    static let dae = DataAcquisitionEngine()
    
    static let layoutEngine = LayoutEngine()
    
    static let documentsController = NSDocumentController()
}
