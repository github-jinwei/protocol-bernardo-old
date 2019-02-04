//
//  LayoutDocument.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutDocument: NSDocument {
    internal var _layout:Layout!
    
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        // Make sure we selected a package
        guard fileWrapper.isDirectory else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        // Make sure there is a Layout File to read from
        Swift.print(fileWrapper.fileWrappers)
    }
    
    override func write(to url: URL, ofType typeName: String) throws {
        // Start by making sure our package directory exist
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Swift.print("Could not create layout package : \(error.localizedDescription)")
        }
        
        // Now save the layout in it
        do {
            let layoutFileURL = url.appendingPathComponent("layout.pbdeviceslayout")
            let layoutData = try JSONEncoder().encode(_layout)
            try layoutData.write(to: layoutFileURL, options: [.atomicWrite])
        } catch {
            Swift.print("Could not save the layout file : \(error.localizedDescription)")
        }
    }
}
