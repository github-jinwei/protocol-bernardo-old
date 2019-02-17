//
//  LayoutDocument.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-04.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

/// A Layout Document represent a stored .pblayout package
class LayoutDocument: NSDocument {
    /// The layout
    var layout: Layout = Layout()
    
    /// The calibration profiles
    var calibrationsProfiles: [String: LayoutCalibrationProfile] = [:]
    
    /// The window controller managed by this document
    fileprivate var layoutWindow: LayoutWindowController! = nil
    
    /// Tell the document is as been edited, and should adopt an "unsaved document"
    /// behaviour
    func markAsEdited() {
        layoutWindow.setDocumentEdited(true)
    }
}

// MARK: - Document IO
extension LayoutDocument {

    /// Write the content of the package
    ///
    /// - Parameter typeName: _
    /// - Returns: The FileWrapper to write
    /// - Throws: _
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        let rootDir = FileWrapper(directoryWithFileWrappers: [:])
        
        // Add the layout file wrapper
        let layoutData = try! JSONEncoder().encode([layout])
        rootDir.addRegularFile(withContents: layoutData, preferredFilename: "layout.pbdeviceslayout")
        
        // Add the calibrations profiles files wrapper
        calibrationsProfiles.forEach { name, profile in
            let calibrationData = try! JSONEncoder().encode([profile])
            rootDir.addRegularFile(withContents: calibrationData, preferredFilename: "\(name).pblayoutcalibration")
        }

        layoutWindow.setDocumentEdited(false)

        return rootDir
    }

    
    /// Read the content of the given filewrapper into memory
    ///
    /// - Parameters:
    ///   - fileWrapper: FileWrapper of an existing package
    ///   - typeName: _
    /// - Throws: _
    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        // Parse all the files in the directory and load or store them based on their extension
        fileWrapper.fileWrappers?.forEach { name, wrapper in
            
            switch name.fileExtension {
            // Layout file
            case "pbdeviceslayout":
                let layoutData = wrapper.regularFileContents!
                layout = try! JSONDecoder().decode([Layout].self, from: layoutData)[0]
                
            // Calibration file
            case "pblayoutcalibration":
                let calibrationData = wrapper.regularFileContents!
                let calibrationProfile = try! JSONDecoder().decode([LayoutCalibrationProfile].self, from: calibrationData)[0]
                calibrationsProfiles[name.fileNameWithoutExtension] = calibrationProfile
                
            // Unknown file extension, ignore
            default: return
            }
        }

        // Add a reference to this document on each calibration profile
        calibrationsProfiles.forEach { profileName, profile in
            profile.document = self
        }
    }
}


// ///////////////////////
// MARK: - Document window
extension LayoutDocument {

    override func makeWindowControllers() {
        // If the layout window is missing, let's create it
        guard layoutWindow == nil else { return }

        let windowController = NSStoryboard(name: "Layout", bundle: nil).instantiateInitialController()

        layoutWindow = windowController as? LayoutWindowController
        addWindowController(layoutWindow)
    }

}

// ///////////////////
// MARK: - Calibration
extension LayoutDocument {
    /// Create a new calibration profile inside the current layout
    ///
    /// - Parameter name: Name of the calibration profile to create
    /// - Returns: A reference to the newly created profile
    func makeCalibrationProfile(withName name: String) -> LayoutCalibrationProfile {
        calibrationsProfiles[name] = LayoutCalibrationProfile(name: name)
        markAsEdited()
        
        return calibrationsProfiles[name]!
    }
}
