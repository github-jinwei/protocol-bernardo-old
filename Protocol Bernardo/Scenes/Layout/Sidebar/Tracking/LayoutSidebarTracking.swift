//
//  LayoutSidebarTracking.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutSidebarTracking: NSViewController {
    var canvas: LayoutCanvas!

    /// Reference to the Layout Document
    weak var document: LayoutDocument?

    /// Reference to the calibration profile
    weak var profile: LayoutCalibrationProfile?

    /// The current tracking session
    var trackingSession: TrackingSession? {
        didSet {
            if trackingSession == nil {
                resetAll()
                return
            }

            trackingSession?.document = document
            toggleRecordingButton.isEnabled = true
        }
    }

    /// Tell if the session is currently recording
    var isRecording: Bool {
        return trackingSession?.isTracking ?? false
    }

    // ///////////////
    // MARK: - Outlets

    /// The list of available sessions
    @IBOutlet weak var sessionsList: NSPopUpButton!

    /// The button to create a new session
    @IBOutlet weak var newSessionButton: NSButton!

    /// Label of the session's start time
    @IBOutlet weak var recordingStartLabel: NSTextField!

    /// Label of the session's recording duration
    @IBOutlet weak var recordingDurationLabel: NSTextField!

    /// Start/Stop recording button
    @IBOutlet weak var toggleRecordingButton: NSButton!

    /// Label with the number of users currently tracked
    @IBOutlet weak var usersTrackedLabel: NSTextField!

    /// Count of users ever tracked for this session
    @IBOutlet weak var totalUsersTrackedLabel: NSTextField!

    /// Export session button
    @IBOutlet weak var exportSessionButton: NSButton!

    /// Delete session button
    @IBOutlet weak var deleteSessionButton: NSButton!
}

// /////////////////
// MARK: - Lifecycle
extension LayoutSidebarTracking {
    override func viewDidAppear() {
        fillTrackingSessionsList()
    }
}

// ////////////////
// MARK: - IBAction
extension LayoutSidebarTracking {

    /// Called by the sessions list when the user select a tracking session
    ///
    /// - Parameter sender: The sessions list
    @IBAction func setTrackingProfile(_: NSPopUpButton) {
        if sessionsList.indexOfSelectedItem == 0 {
            trackingSession = nil
            return
        }

        let sessionName = sessionsList.titleOfSelectedItem!
        trackingSession = document?.openTrackingSession(withName: sessionName)
    }

    /// Called when the user wants to create a new session
    ///
    /// - Parameter sender: The "new session" button
    @IBAction func newSession(_: NSButton) {
        let sheet = storyboard!.instantiateController(withIdentifier: "newTrackingSessionSheet") as! NewTrackingSessionPanel

        sheet.createSessionDelegate = createTrackingSession

        self.presentAsSheet(sheet)
    }

    /// Create a new tracking session with the given name
    ///
    /// - Parameter name: Name of the session to create
    func createTrackingSession(_ name: String) -> Void {
        trackingSession = document?.makeTrackingSession(withName: name)

        // Refresh the list of sessions
        fillTrackingSessionsList()

        // Select the newly created one
        sessionsList.selectItem(withTitle: name)
    }

    /// Called by the user to start/stop recording
    ///
    /// - Parameter sender: The start/stop recording button
    @IBAction func toggleRecording(_: NSButton) {
        guard let trackingSession = self.trackingSession else {
            toggleRecordingButton.title = "Start"
            toggleRecordingButton.isEnabled = false
            return
        }

        if trackingSession.isTracking {
            trackingSession.endSession();

            toggleRecordingButton.title = "Start"
            return
        }

        trackingSession.startSession()
        toggleRecordingButton.title = "Stop"
    }

    /// Called by the user to export the current session
    ///
    /// - Parameter sender: The "export" button
    @IBAction func exportSession(_: NSButton) {

    }

    /// Called by the user to delete the session
    ///
    /// - Parameter sender: The "delete" button
    @IBAction func deleteSession(_: NSButton) {

    }
}

extension LayoutSidebarTracking {
    /// Populate the list of existing tracking sessions
    func fillTrackingSessionsList() {
        var sessions: [String] = ["No Session"]

        if let document = self.document {
            for (sessionName, _) in document.trackingSessions {
                sessions.append(sessionName)
            }
        }

        sessionsList.removeAllItems()
        sessionsList.addItems(withTitles: sessions)

        sessionsList.itemArray.first!.isEnabled = false
    }
}

// MARK: - LayoutSidebar
extension LayoutSidebarTracking: LayoutSidebar {
    func setSelectedElement(_ element: LayoutCanvasElement?) {
        // Unused
    }
}

extension LayoutSidebarTracking {
    /// Reset the sidebar components
    func resetAll() {
        recordingStartLabel.integerValue = 0
        recordingDurationLabel.integerValue = 0

        toggleRecordingButton.isEnabled = false

        usersTrackedLabel.integerValue = 0
        totalUsersTrackedLabel.integerValue = 0

        exportSessionButton.isEnabled = false
        deleteSessionButton.isEnabled = false
    }
}
