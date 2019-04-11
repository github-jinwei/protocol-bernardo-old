//
//  LayoutCanvasDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol LayoutCanvasDelegate: AnyObject {
	/// Informs the delegate the layoutView finished its initial drawing
	///
	/// - Parameter _: The current layoutView
	func canvasDidAppeared(_: LayoutViewController, document: LayoutDocument)

	/// Informs the delegate the layoutView changed
	///
	/// - Parameter _: The current layoutView
	func canvas(_: LayoutViewController, didChange document: LayoutDocument)

	/// Tell the delegate the layoutView selection has changed
	///
	/// - Parameters:
	///   - _: The current layoutView
	///   - element: The currently selected element, might be nil if there is no selection
	func canvas(_: LayoutViewController, selectionChanged element: LayoutCanvasElement?)
}


// MARK: - Optional methods
extension LayoutCanvasDelegate {
	func canvasDidAppeared(_: LayoutViewController, document: LayoutDocument) {}

	func canvas(_: LayoutViewController, didChange document: LayoutDocument) {}

	func canvas(_: LayoutViewController, selectionChanged element: LayoutCanvasElement?) {}
}
