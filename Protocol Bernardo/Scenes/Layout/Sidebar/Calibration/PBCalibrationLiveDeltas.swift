//
//  PBCalibrationLiveDeltas.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBCalibrationLiveDeltas: NSView {
    internal let emptyString: String = "-"

    @IBOutlet var orientationDeltaField: NSTextField!
    @IBOutlet var xPositionDeltaField: NSTextField!
    @IBOutlet var yPositionDeltaField: NSTextField!
    @IBOutlet var heightDeltaField: NSTextField!

    /// Update the deltas fields properly using the given Calibration Deltas
    ///
    /// - Parameter deltas: _
    func show(deltas: CalibrationDeltas?) {
        // Reset the fields
        clear()

        // If there is no deltas, do nothing
        guard let deltas = deltas else { return }

        // Do we have an orientation deltas ?
        guard let orientationDeltaRad = deltas.orientation else {
            // No orientation delta, show only the positions
            showPositionsDeltas(deltas)
            return
        }

        // get the orientation delta in degrees and display it
        let orientationDelta = rad2deg(orientationDeltaRad).rounded()
        orientationDeltaField.floatValue = orientationDelta

        // If the orientation delta isn't low enough, display empty strings for
        // the other properties
        guard abs(orientationDelta) < 3.0 else {
            xPositionDeltaField.stringValue = emptyString
            yPositionDeltaField.stringValue = emptyString
            heightDeltaField.stringValue = emptyString

            return
        }

        showPositionsDeltas(deltas)
    }

    /// Display the positioning deltas (X, Y and height) in the proper unit
    ///
    /// - Parameter deltas: _
    internal func showPositionsDeltas(_ deltas: CalibrationDeltas) {
        // Display the positions deltas
        xPositionDeltaField.floatValue = deltas.xPosition / 10.0
        yPositionDeltaField.floatValue = deltas.yPosition / 10.0
        heightDeltaField.floatValue = deltas.height / 10.0
    }

    /// Replace the labels values with empty strings
    func clear() {
        orientationDeltaField.stringValue = emptyString
        xPositionDeltaField.stringValue = emptyString
        yPositionDeltaField.stringValue = emptyString
        heightDeltaField.stringValue = emptyString
    }
}
