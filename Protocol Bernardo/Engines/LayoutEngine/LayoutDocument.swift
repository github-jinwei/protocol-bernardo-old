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
    /// All the filetypes, and extensions, associated with a Layout Document
    ///
    /// - package: The layout package
    /// - layout: The layout file
    /// - calibrationProfile: A calibration profile
    /// - trackingSession: A Tracking session package
    /// - trackingFile: A Tracking file
    enum FileTypes: String {
        case package = "pblayout"
        case layout = "pbdeviceslayout"
        case calibrationProfile = "pblayoutcalibration"
        case trackingSession = "pbtrackingsession"
        case trackingFile = "bvh"

        /// Takes the given string and append the extension (with the dot)
        /// for the current FileType
        ///
        /// - Parameter fileName: Name of the file
        /// - Returns: The full file name with the extension
        func named(_ fileName: String) -> String{
            return fileName + "." + self.rawValue
        }
    }

    /// The window controller managed by this document
    private var layoutWindow: LayoutWindowController! = nil

    /// The layout
    var layout: Layout = Layout()
    
    /// The calibration profiles
    var calibrationsProfiles: [String: LayoutCalibrationProfile] = [:]

    /// The tracking sessions
    var trackingSessions: [String: FileWrapper] = [:]

    /// The currently opened tracking session
    private var openedTrackingSession: TrackingSession?
    
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
        rootDir.addRegularFile(withContents: layoutData,
                               preferredFilename: FileTypes.layout.named("layout"))
        
        // Add the calibrations profiles files wrapper
        for (name, profile) in calibrationsProfiles {
            let calibrationData = try! JSONEncoder().encode([profile])
            rootDir.addRegularFile(withContents: calibrationData,
                                   preferredFilename: FileTypes.calibrationProfile.named(name))
        }

        // Save the opened tracking session if needed
        if openedTrackingSession != nil {
            trackingSessions[openedTrackingSession!.name] = openedTrackingSession!.wrapper
        }

        // Insert the tracking sessions
        for (_, wrapper) in trackingSessions {
            rootDir.addFileWrapper(wrapper)
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
        guard let fileWrappers = fileWrapper.fileWrappers else { return }

        // Parse all the files in the directory and load or store them based on their extension
        for (name, wrapper) in fileWrappers {
            switch FileTypes(rawValue: name.fileExtension)! {
            // Layout file
            case .layout:
                let layoutData = wrapper.regularFileContents!
                layout = try! JSONDecoder().decode([Layout].self, from: layoutData)[0]
                
            // Calibration file
            case .calibrationProfile:
                let calibrationData = wrapper.regularFileContents!
                let calibrationProfile = try! JSONDecoder().decode([LayoutCalibrationProfile].self, from: calibrationData)[0]
                calibrationsProfiles[name.fileNameWithoutExtension] = calibrationProfile

            case .trackingSession:
                trackingSessions[name.fileNameWithoutExtension] = wrapper
                break
                
            default: break
            }
        }

        // Add a reference to this document on each calibration profile
        for (_, profile) in calibrationsProfiles {
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


// ////////////////
// MARK: - Tracking
extension LayoutDocument {
    /// Create a new tracking session and start listening
    ///
    /// - Parameter name: Name of the calibration profile to create
    /// - Returns: A reference to the newly created profile
    func makeTrackingSession(withName name: String) -> TrackingSession {
        // If a tracking session is already opened, save the document before closing it
        if openedTrackingSession != nil {
            openedTrackingSession!.endSession()
            self.save(nil)
        }

        // Create and insert the new tracking session
        openedTrackingSession = TrackingSession(name: name)
        trackingSessions[openedTrackingSession!.name] = openedTrackingSession!.wrapper

        markAsEdited()

        return openedTrackingSession!
    }

    /// Open an existing tracking session
    ///
    /// - Parameter name: Name of the calibration profile to create
    /// - Returns: A reference to the newly created profile
    func openTrackingSession(withName name: String) -> TrackingSession {
        // If a tracking session is already opened, save the document before closing it
        if openedTrackingSession != nil {
            openedTrackingSession!.endSession()
            self.save(nil)
        }

        // Create and insert the new tracking session
        openedTrackingSession = TrackingSession(wrapper: trackingSessions[name]!)

        markAsEdited()

        return openedTrackingSession!
    }
}
