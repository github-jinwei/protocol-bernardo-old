//
//  NSDocumentDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

protocol NSDocumentDelegate: AnyObject {
    /// tell the receiver the document has just finished a save operation
    ///
    /// - Parameters:
    ///   - doc: The document
    ///   - didSave: True if the document was saved, false otherwise
    ///   - contextInfo: _
    func document(_ doc: NSDocument, didSave: Bool, contextInfo: UnsafeRawPointer?)
}
