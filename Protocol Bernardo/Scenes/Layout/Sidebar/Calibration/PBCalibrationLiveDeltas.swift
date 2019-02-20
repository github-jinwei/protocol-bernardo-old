//
//  PBCalibrationLiveDeltas.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-13.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class PBCalibrationLiveDeltas: NSView {

    internal let okColor = NSColor.systemGreen
    internal let emptyString: String = "-"

    @IBOutlet weak var orientationBox: NSBox!
    @IBOutlet weak var orientationDeltaField: NSTextField!
    @IBOutlet weak var orientationLabel: NSTextField!
    @IBOutlet weak var orientationUnitLabel: NSTextField!

    @IBOutlet weak var xPositionBox: NSBox!
    @IBOutlet weak var xPositionDeltaField: NSTextField!
    @IBOutlet weak var xPositionLabel: NSTextField!
    @IBOutlet weak var xPositionUnitLabel: NSTextField!

    @IBOutlet weak var yPositionBox: NSBox!
    @IBOutlet weak var yPositionDeltaField: NSTextField!
    @IBOutlet weak var yPositionLabel: NSTextField!
    @IBOutlet weak var yPositionUnitLabel: NSTextField!

    @IBOutlet weak var heightBox: NSBox!
    @IBOutlet weak var heightDeltaField: NSTextField!
    @IBOutlet weak var heightLabel: NSTextField!
    @IBOutlet weak var heightUnitLabel: NSTextField!

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
        guard abs(orientationDelta) < 15.0 else {
            xPositionDeltaField.stringValue = emptyString
            yPositionDeltaField.stringValue = emptyString
            heightDeltaField.stringValue = emptyString

            return
        }

        setOrientationOKAppearance()

        showPositionsDeltas(deltas)
    }

    /// Display the positioning deltas (X, Y and height) in the proper unit
    ///
    /// - Parameter deltas: _
    internal func showPositionsDeltas(_ deltas: CalibrationDeltas) {
        // Display the positions deltas
        xPositionDeltaField.floatValue = deltas.xPosition / 10.0

        if abs(xPositionDeltaField.floatValue) < 5 {
            setXPositionOKAppearance()
        }

        yPositionDeltaField.floatValue = deltas.yPosition / 10.0

        if abs(yPositionDeltaField.floatValue) < 5 {
            setYPositionOKAppearance()
        }

        heightDeltaField.floatValue = deltas.height / 10.0

        if abs(heightDeltaField.floatValue) < 5 {
            setHeightOKAppearance()
        }
    }

    /// Replace the labels values with empty strings
    func clear() {
        setDefaultAppearance()

        orientationDeltaField.stringValue = emptyString
        xPositionDeltaField.stringValue = emptyString
        yPositionDeltaField.stringValue = emptyString
        heightDeltaField.stringValue = emptyString
    }

    /// Set the UI Elementsd to their default appearance (White-ish)
    func setDefaultAppearance() {
        orientationBox.borderColor = .secondaryLabelColor
        orientationLabel.textColor = .labelColor
        orientationDeltaField.textColor = .labelColor
        orientationUnitLabel.textColor = .labelColor

        xPositionBox.borderColor = .secondaryLabelColor
        xPositionDeltaField.textColor = .labelColor
        xPositionLabel.textColor = .labelColor
        xPositionUnitLabel.textColor = .labelColor

        yPositionBox.borderColor = .secondaryLabelColor
        yPositionDeltaField.textColor = .labelColor
        yPositionLabel.textColor = .labelColor
        yPositionUnitLabel.textColor = .labelColor

        heightBox.borderColor = .secondaryLabelColor
        heightDeltaField.textColor = .labelColor
        heightLabel.textColor = .labelColor
        heightUnitLabel.textColor = .labelColor
    }

    /// Set the orientation block green
    func setOrientationOKAppearance() {
        orientationBox.borderColor = okColor
        orientationLabel.textColor = okColor
        orientationDeltaField.textColor = okColor
        orientationUnitLabel.textColor = okColor
    }

    /// Set the x position block green
    func setXPositionOKAppearance() {
        xPositionBox.borderColor = okColor
        xPositionDeltaField.textColor = okColor
        xPositionLabel.textColor = okColor
        xPositionUnitLabel.textColor = okColor
    }

    /// Set the y position block green
    func setYPositionOKAppearance() {
        yPositionBox.borderColor = okColor
        yPositionDeltaField.textColor = okColor
        yPositionLabel.textColor = okColor
        yPositionUnitLabel.textColor = okColor
    }

    /// Set the height block green
    func setHeightOKAppearance() {
        heightBox.borderColor = okColor
        heightDeltaField.textColor = okColor
        heightLabel.textColor = okColor
        heightUnitLabel.textColor = okColor
    }
}
