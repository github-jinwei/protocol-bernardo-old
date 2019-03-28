//
//  TrackingSession.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A Tracking Session represent a package holding numerous TrackedUsers.
class TrackingSession {
    /// The name of the session, match the package name without extension
    var name: String

    /// Tell if the session is active
    var isTracking: Bool = false

    /// Reference to the layout document
    weak var document: LayoutDocument?

    /// All the users tracked by this session
    private var trackedUsers = [TrackedUser]()

    /// All the users already existing in the session (in case of reopen)
    private var existingTrackings = [String: FileWrapper]()

    /// Creates a new session with the given name
    ///
    /// - Parameter name: Name of the session to create
    init(name: String) {
        self.name = name

        App.usersEngine.addObserver(self)
    }

    /// Open the session using the given fileWrapper
    ///
    /// - Parameter wrapper: A Wrapper pointing to an existing session package
    init(wrapper: FileWrapper) {
        guard wrapper.filename!.fileExtension == LayoutDocument.FileTypes.trackingSession.rawValue else {
            fatalError("A Tracking session can only be open with a '\(LayoutDocument.FileTypes.trackingSession.rawValue)' file extension. '\(wrapper.filename!.fileExtension)' found.")
        }

        // Set the session name
        self.name = wrapper.filename!.fileNameWithoutExtension

        // Store the existing wrappers
        existingTrackings = wrapper.fileWrappers!

        App.usersEngine.addObserver(self)
    }

    /// Start recording users positions
    func startSession() {
        isTracking = true
    }

    /// Stop recording
    func endSession() {
        guard isTracking else { return }

        isTracking = false
    }
}

// MARK: - Accessors
extension TrackingSession {
    /// Gives the tracked user for the given user
    ///
    /// - Parameter user: the user to search with
    /// - Returns: The tracked user or nil
    func trackedUser(forUser user: User) -> TrackedUser? {
        return trackedUsers.first(where: { $0.user === user })
    }

    /// The fileWrapper for this session
    var wrapper: FileWrapper {
        var userWrapper: [String: FileWrapper] = trackedUsers.reduce([String: FileWrapper]()) { dict, user in
            // Insert the wrapper
            var dict = dict
            dict[user.fileName] = user.wrapper
            return dict
        }

        // Insert the existing users
        for (k, v) in existingTrackings {
            userWrapper[k] = v
        }

        // Create the session wrapper with all the tracked users wrappers
        let wrapper = FileWrapper(directoryWithFileWrappers: userWrapper)
        wrapper.preferredFilename = LayoutDocument.FileTypes.trackingSession.named(name)

        return wrapper
    }
}

// MARK: - UsersEngineDelegate
extension TrackingSession: UsersEngineDelegate {
    func userEngine(_: UsersEngine, startedTrackingUser user: User) {
        guard isTracking else { return }

        trackedUsers.append(TrackedUser(forUser: user))
        document?.markAsEdited()
    }

    func userEngine(_: UsersEngine, user: User, physicUpdated physic: PhysicalUser) {
        guard isTracking else { return }

        guard let trackedUser = trackedUser(forUser: user) else { return }

        trackedUser.add(physic: physic)
        document?.markAsEdited()
    }

    func userEngine(_: UsersEngine, mergedUser: User, inUser _: User) {
        guard isTracking else { return }

        // In case of a merging, we discard the merged user and keep only the second one
        trackedUsers.removeAll(where: { $0.user === mergedUser })
        document?.markAsEdited()
    }


    func userEngine(_: UsersEngine, stoppedTrackingUser user: User) {
        guard let trackedUser = trackedUser(forUser: user) else { return }

        // We will not be tracking this user again, write its file
        document?.markAsEdited()
        document?.save(nil)

        // Store the user wrapper
        existingTrackings[trackedUser.fileName] = trackedUser.wrapper

        // And remove it
        trackedUsers.removeAll(where: { $0 === user })
    }

    func usersPhysicsHistorySize(_: UsersEngine) -> UInt {
        return 3
    }
}
