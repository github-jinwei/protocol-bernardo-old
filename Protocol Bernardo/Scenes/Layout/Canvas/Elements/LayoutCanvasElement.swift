//
//  LayoutElement.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

import SpriteKit
import AppKit

protocol LayoutCanvasElement: AnyObject {
    /// The element delegate
    var delegate: LayoutCanvasElementDelegate! { get set }

    // /////////////////
    // MARK: - Selection

    /// Tell if the device is currently selected
    var isSelected: Bool { get set }

    /// Called by a user event to mark the element as selected
    func select()
    
    /// Called by a user event to deselect the element
    func deselect()

    /// Called when the element is remove to let it properly remove its content
    func deleteActions()

    /// Change the element appearance to the specified appearance
    ///
    /// - Parameter appearance: The element appearance value
    func set(appearance: LayoutCanvasElementAppearance)

    // ////////////////////
    // MARK: - User actions
    
    /// Allows the element to receive keyDown events
    ///
    /// - Parameter event: a KeyDown event
    func keyDown(with event: NSEvent)
    
    /// Allos the user to drag the element around
    ///
    /// - Parameter event:
    func mouseDragged(with event: NSEvent)

    // /////////////////////////
    // MARK: - Internal methods

    /// Gives the viewController holding the parameters view for the element
    ///
    /// - Returns:
    func getParametersController() -> NSViewController
    
    /// Tell if the cursor described by the given mouse event falls inside the
    /// device trigger areas
    ///
    /// - Parameter event: Mouse event
    /// - Returns: True if the cursor is inside the trigger area, false otherwise
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool
}

// MARK: - Default Implementations
extension LayoutCanvasElement {
    func locationInTriggerArea(forEvent event: NSEvent) -> Bool {
        return false
    }

    /// Change the device state to selected
    func markAsSelected() {
        delegate?.element(self, selectionChanged: true)
    }

    /// Update the device state to reflect is selected state.
    /// You should not called this method directly. Use `markAsSelected` instead.
    func select() {
        isSelected = true

        // Update appearance to reflect change
        set(appearance: .selected)
    }

    /// Change the device state to idle
    func markAsIdle() {
        delegate?.element(self, selectionChanged: false)
    }

    /// Update the device state to reflect is deselected state.
    /// You should not called this method directly. Use `markAsIdle` instead.
    func deselect() {
        isSelected = false

        // Update appearance to reflect change
        set(appearance: .idle)
    }

    /// Delete the device, removes it from the layout and fron the view
    func delete() {
        // Asks the user before going further obviously

        let confirmModal = NSAlert()
        confirmModal.alertStyle = .warning
        confirmModal.messageText = "Are you sure you want to delete this element ?"
        confirmModal.addButton(withTitle: "Delete Element")
        confirmModal.addButton(withTitle: "Cancel")

        confirmModal.beginSheetModal(for: delegate.canvasWindow()) { response in
            guard response == NSApplication.ModalResponse.alertFirstButtonReturn else {
                // Alert was canceled, do nothing
                return
            }

            self.markAsIdle()
            self.deleteActions()
            self.delegate?.elementWillBeRemoved(self)
        }
    }
}

// MARK: - Useful methods
extension LayoutCanvasElement {
    /// Gives the highlight color for the current MacOS Style
    internal var highlightColor: NSColor {
        return NSColor.controlAccentColor
    }
}
