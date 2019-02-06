//
//  LayoutSidebar.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol LayoutSidebar: AnyObject {
    var canvas: LayoutCanvas? { get set }
    
    /// Used to tell the sidebar that a new element has been selected
    ///
    /// - Parameter element: The selected element or nil if no elements are selected
    func setSelectedElement(_ element: LayoutCanvasElement?)
}
