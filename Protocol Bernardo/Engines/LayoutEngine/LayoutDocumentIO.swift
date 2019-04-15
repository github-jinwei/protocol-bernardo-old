//
//  LayoutDocumentIO.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

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

//		updateChangeCount(.changeCleared)

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

		// reopen the latest profile
		if let profileName = layout.profile {
			set(calibrationProfile: profileName)
		}
	}
}
