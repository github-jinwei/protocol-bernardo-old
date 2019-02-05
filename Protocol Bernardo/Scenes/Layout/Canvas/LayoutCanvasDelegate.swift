//
//  LayoutCanvasDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// Delegate used by the Layout Canvas to informs its receiver on events happening
protocol LayoutCanvasDelegate: AnyObject {
    /// Informs the delegate that the canvas content has been changed
    ///
    /// - Parameters:
    ///   - canvas: The canvas holding the edited element
    func canvasWasChanged(_ canvas: LayoutCanvas)
    
    
    /// Informs the delegate the canvas selection has changed
    ///
    /// - Parameters:
    ///   - canvas: The current canvas
    ///   - element: The currently selected element, might be nil if there is no selection
    func canvas(_ canvas: LayoutCanvas, selectionChanged element: LayoutCanvasElement?)
}
