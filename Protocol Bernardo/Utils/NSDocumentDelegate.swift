//
//  NSDocumentDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-05.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

protocol NSDocumentDelegate: AnyObject {
    func document(_ doc: NSDocument, didSave: Bool, contextInfo: UnsafeRawPointer?)
}
