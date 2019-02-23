//
//  LayoutCanvasElementDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit

/// Used by a canvas element to propagate its events and access properties of its
/// parent canvas
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

    /// Tell the delegate the device selection changed
    ///
    /// - Parameters:
    ///   - element: _
    ///   - isSelected: True if the element is selected, false otherwise
    func element(_ element: LayoutCanvasElement, selectionChanged isSelected: Bool)

    /// Tells the delegate to duplicate the device element
    ///
    /// - Parameter element: The device element to duplicate
    func duplicateDeviceElement(_ element: LayoutCanvasDevice)

    /// Tells the delegate to duplicate the device element
    ///
    /// - Parameter element: The device element to duplicate
    func duplicateLineElement(_ element: LayoutCanvasLine)


    /// Asks the delegate for the canvas root node
    ///
    /// - Returns: The canvas root node
    func canvasRootNode() -> SKNode

    /// Asks the delegate for the canvas window
    ///
    /// - Returns: The canvas contaner window
    func canvasWindow() -> NSWindow

    /// Asks the delegate for the currently selected calibration profile
    ///
    /// - Parameter forDevice: The device to get the calibration profile for
    /// - Returns: The given device's calibration profile
    func deviceProfile(forDevice: Device) -> DeviceCalibrationProfile?
}
