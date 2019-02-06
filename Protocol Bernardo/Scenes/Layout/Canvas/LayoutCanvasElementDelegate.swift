//
//  LayoutCanvasElementDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol LayoutCanvasElementDelegate: AnyObject {
    /// Tells the delegate that the element has changed
    ///
    /// - Parameter element: _
    func elementDidChange(_ element: LayoutCanvasElement)
    
    /// Tells the delegate the element will be removed
    ///
    /// - Parameter element: _
    func elementWillBeRemoved(_ element: LayoutCanvasElement)
    
    /// Asks the delegate if the element can be edited
    ///
    /// - Parameter element: _
    func elementCanBeEdited(_ element: LayoutCanvasElement) -> Bool
}
