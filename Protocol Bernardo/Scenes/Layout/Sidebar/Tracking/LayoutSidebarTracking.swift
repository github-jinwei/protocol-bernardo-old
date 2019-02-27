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

    weak var profile: LayoutCalibrationProfile?

    var trackingSession: TrackingSession? {
        didSet {
            if trackingSession == nil {
                resetAll()
                return
            }


        }
    }

    var isRecording: Bool {
        return trackingSession?.isTracking ?? false
    }

    // ///////////////
    // MARK: - Outlets

    @IBOutlet weak var sessionsList: NSPopUpButton!

    @IBOutlet weak var newSessionButton: NSButton!

    @IBOutlet weak var recordingStartLabel: NSTextField!

    @IBOutlet weak var recordingDurationLabel: NSTextField!

    @IBOutlet weak var toggleRecordingButton: NSButton!

    @IBOutlet weak var usersTrackedLabel: NSTextField!

    @IBOutlet weak var totalUsersTrackedLabel: NSTextField!

    @IBOutlet weak var exportSessionButton: NSButton!

    @IBOutlet weak var deleteSessionButton: NSButton!

    @IBAction func setTrackingProfile(_ sender: NSPopUpButton) {
        if sessionsList.indexOfSelectedItem == 0 {
            trackingSession = nil
            return
        }

        let sessionName = sessionsList.titleOfSelectedItem!
        trackingSession = document?.openTrackingSession(withName: sessionName)
    }

    @IBAction func newSession(_ sender: NSButton) {
        let sheet = storyboard!.instantiateController(withIdentifier: "newTrackingSessionSheet") as! NewTrackingSessionPanel

        sheet.createSessionDelegate = createTrackingSession

        self.presentAsSheet(sheet)
    }

    func createTrackingSession(_ name: String) -> Void {
        trackingSession = document?.makeTrackingSession(withName: name)

        // Refresh the list of sessions
        fillTrackingSessionsList()

        // Select the newly created one
        sessionsList.selectItem(withTitle: name)
    }

    @IBAction func toggleRecording(_ sender: NSButton) {

    }

    @IBAction func exportSession(_ sender: NSButton) {

    }

    @IBAction func deleteSession(_ sender: NSButton) {

    }
}

extension LayoutSidebarTracking {
    func fillTrackingSessionsList() {
        var sessions: [String] = ["No Profile"]

        if let document = self.document {
            for (sessionName, _) in document.trackingSessions {
                sessions.append(sessionName)
            }
        }

        sessions.append("+ New Profile")

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
