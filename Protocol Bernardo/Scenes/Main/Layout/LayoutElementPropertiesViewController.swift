//
//  LayoutElementViewController.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-17.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

protocol LayoutElementPropertiesViewController: NSViewController {


	var xPositionField: NSTextField! { get }
	var xPositionStepper: NSStepper! { get }

	var yPositionField: NSTextField! { get }
	var yPositionStepper: NSStepper! { get }

	var orientationField: NSTextField! { get }
	var orientationStepper: NSStepper! { get }
}

extension LayoutElementPropertiesViewController {
	func set(position: CGPoint) {
		xPositionField?.doubleValue = Double(position.x)
		xPositionStepper?.doubleValue = Double(position.x)

		yPositionField?.doubleValue = Double(position.y)
		yPositionStepper?.doubleValue = Double(position.y)
	}

	func set(orientation: CGFloat) {
		orientationField?.doubleValue = Double(orientation)
		orientationStepper?.doubleValue = Double(orientation)
	}
}
