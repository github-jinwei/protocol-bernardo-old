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
        case trackingFile = "pba"

        /// Takes the given string and append the extension (with the dot)
        /// for the current FileType
        ///
        /// - Parameter fileName: Name of the file
        /// - Returns: The full file name with the extension
        func named(_ fileName: String) -> String {
            return fileName + "." + self.rawValue
        }
    }

    /// The window controller managed by this document
    private var window: MainWindowController! = nil

    /// The layout
    internal var layout: Layout = Layout()
    
    /// The calibration profiles
    var calibrationsProfiles: [String: LayoutCalibrationProfile] = [:]

	/// reference to the currently selected profile
	weak var profile: LayoutCalibrationProfile? {
		didSet {
			observers.forEach { $0.layout(self, calibrationProfileDidChanged: profile) }
		}
	}

    /// The tracking sessions
    var trackingSessions: [String: FileWrapper] = [:]

    /// The currently opened tracking session
    internal var openedTrackingSession: TrackingSession?
    
    /// Tell the document is as been edited, and should adopt an "unsaved document"
    /// behaviour
    func markAsEdited() {
        updateChangeCount(.changeDone)
    }

    override class var autosavesInPlace: Bool {
        return true
    }

	weak var layoutView: LayoutViewController!

	internal var observers: [LayoutDocumentObserver] = []

	func addObserver(_ observer: LayoutDocumentObserver) {
		observers.append(observer)
	}

	func removeObserver(_ observer: LayoutDocumentObserver) {
		observers.removeAll { $0 === observer }
	}
}


// ///////////////////////
// MARK: - Document window
extension LayoutDocument {
    override func makeWindowControllers() {
        // If the layout window is missing, let's create it
        guard window == nil else { return }

        let windowController = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController()

        window = windowController as? MainWindowController
        addWindowController(window)
    }

	override func close() {
		super.close()

		if App.layoutEngine.documentsController.documents.isEmpty {
			App.core.showHomeWindow()
		}
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

		App.logs?.insert(message: "New calibration profile `\(name)` added", prefix: "Layout")
        
        return calibrationsProfiles[name]!
    }

	func removeCalibrationProfile(withName name: String) {
		if layout.profile == name {
			layout.profile = nil
		}

		calibrationsProfiles.removeValue(forKey: name)

		markAsEdited()

		App.logs?.insert(message: "Calibration profile `name` removed", prefix: "Layout")
	}

	func set(calibrationProfile profileName: String?) {
		guard let profileName = profileName else {
			profile = nil
			return
		}

		guard let selectedProfile = calibrationsProfiles[profileName] else {
			profile = nil
			return
		}

		layout.profile = profileName
		profile = selectedProfile

		for obs in observers {
			obs.layout(self, calibrationProfileDidChanged: profile)
		}

		App.usersEngine.profile = profile
		App.logs?.insert(message: "Calibration profile changed to `\(profileName)`", prefix: "Layout")
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

		App.logs?.insert(message: "New tracking session `\(name)` added", prefix: "Layout")

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

		App.logs?.insert(message: "Tracking session `\(name)` opened", prefix: "Layout")

        return openedTrackingSession!
    }
}
