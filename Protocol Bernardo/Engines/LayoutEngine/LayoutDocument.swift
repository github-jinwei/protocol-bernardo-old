//
//  LayoutDocument.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutDocument: NSDocument {
    /// The document delegate
    weak var delegate: NSDocumentDelegate?
    
    /// The name of the devices layout stored in the bundle
    internal let _layoutFileName = "layout.pbdeviceslayout"
    
    /// The layout
    internal var _layout:Layout = Layout()
    
    /// The layout
    var layout: Layout {
        return _layout
    }
    
    /// The window controller managed by this document
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
        
        _layout = try! JSONDecoder().decode([Layout].self,
                                            from: layoutData)[0]
    }
    
    
    override func write(to url: URL, ofType typeName: String) throws {
        // Start by making sure our package directory exist
        Swift.print(url)
        
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSAlert(error: error).runModal()
                return
            }
        }
            
        // Now save the layout in it
        do {
            let layoutFileURL = url.appendingPathComponent("layout.pbdeviceslayout")
            let layoutData = try JSONEncoder().encode([_layout])
            try layoutData.write(to: layoutFileURL, options: [])
        } catch {
            NSAlert(error: error).runModal()
            return
        }
        
        delegate?.document(self, didSave: true, contextInfo: nil)
    }
}


// ///////////////////////
// MARK: - Document window
extension LayoutDocument {
    override func makeWindowControllers() {
        // If the layout window is missing, let's create it
        if _layoutWindow == nil {
            _layoutWindow = NSStoryboard(name: "Layout", bundle: nil).instantiateInitialController() as? LayoutWindowController
            self.addWindowController(_layoutWindow)
        }
    }
}

// ///////////////////
// MARK: - Calibration
extension LayoutDocument{
    var availableCalibrations: [URL] {
        guard let url = self.fileURL else {
            return []
        }
        
        let packageFiles = try! FileManager().contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        
        let calibrationFiles = packageFiles.filter { $0.pathExtension == "pblayoutcalibration" }
        
        return calibrationFiles
    }
    
    func makeCalibrationProfile(withName name: String) -> LayoutCalibrationDocument {
        let calibrationDocument = LayoutCalibrationDocument()
        calibrationDocument.setLayoutDocument(self)
        
        let url = self.fileURL?.appendingPathComponent("\(name).pblayoutcalibration")
        calibrationDocument.fileURL = url
        
        try! calibrationDocument.write(to: calibrationDocument.fileURL!, ofType: "com.prisme.pb.layout.calibration")
        
        return calibrationDocument
    }
    
    /// Open the calibration profile for the given name (with extension) inside
    /// the layout package
    ///
    /// - Parameter name: Name of the calibration profile
    /// - Returns: The calibration profile
    func openCalibrationProfile(named name: String) -> LayoutCalibrationDocument {
        let url = self.fileURL!.appendingPathComponent("\(name).pblayoutcalibration")
        return try! LayoutCalibrationDocument(contentsOf: url, ofType: "com.prisme.pb.layout.calibration")
    }
}
