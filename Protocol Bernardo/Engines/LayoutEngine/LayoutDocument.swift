//
//  LayoutDocument.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutDocument: NSDocument {
    internal let _layoutFileName = "layout.pbdeviceslayout"
    
    internal var _layout:Layout = Layout()
    
    var layout: Layout {
        return _layout
    }
    
    internal var _layoutWindow: LayoutWindowController! = nil
}

// MARK: - Document IO
extension LayoutDocument {
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        // Make sure we selected a package
        guard fileWrapper.isDirectory else {
            Swift.print("Invalid Selection")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        // Make sure there is a Layout File to read from
        let hasLayoutFile: Bool = fileWrapper.fileWrappers!.contains {$0.key == _layoutFileName}
        
        guard hasLayoutFile else {
            Swift.print("Invalid PBLayout")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        // Load the content of the layout and store it
        let layoutData = fileWrapper.fileWrappers![_layoutFileName]!.regularFileContents!
        _layout = try! JSONDecoder().decode([Layout].self, from: layoutData)[0]
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
            let layoutData = try JSONEncoder().encode([_layout])
            try layoutData.write(to: layoutFileURL, options: [.atomicWrite])
        } catch {
            Swift.print("Could not save the layout file : \(error.localizedDescription)")
        }
    }
}


// MARK: - Document window
extension LayoutDocument {
    override func makeWindowControllers() {
        // If the layout window is missing, let's create it
        if _layoutWindow == nil {
            _layoutWindow = NSStoryboard(name: "LayoutEditor", bundle: nil).instantiateInitialController() as? LayoutWindowController
            self.addWindowController(_layoutWindow)
        }
    }
}

