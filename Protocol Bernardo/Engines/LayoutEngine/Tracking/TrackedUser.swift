//
//  TrackedUser.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-23.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// A tracked user holds a BVA file containing a series of movements performed
/// by a user
class TrackedUser {
    /// The user tracked
    weak var user: User?

    /// Unique UUID for this tracked user
    var uuid = UUID().uuidString

    /// URL to the file containing the tracjing data
    ///
    /// In case of a recording, this will to point to a temporary file
    var fileURL: URL!

    /// The recording file representation
    var file: BVHFile!

    /// The filename for this tracked user
    var fileName: String {
        return uuid + ".bvh"
    }

    /// The filewrapper holding the tracked user informations
    var wrapper: FileWrapper {
        // Get File Wrapper for temp file
        return try! FileWrapper(url: fileURL, options: [])
    }

    /// Init and set the user being tracked
    ///
    /// - Parameter user: The user being tracked
    init(forUser user: User) {
        self.user = user
    }
}

// MARK: - Insertions
extension TrackedUser {
    /// Record the given physic in the file
    ///
    /// - Parameter physic: The physic to insert
    func add(physic: PhysicalUser) {
        if file == nil {
            // File is missing, create it
            createFile(withPhysic: physic)
        }

        if file.isClosed {
            return
        }

        file.insert(physic: physic)
    }

    /// End the tracking, close the file. Is is not possible to reopen the file later
    func endTracking() {
        file?.close()
    }

    private func createFile(withPhysic physic: PhysicalUser) {
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

        try! FileManager.default.createDirectory(
            at: URL(fileURLWithPath: NSTemporaryDirectory()),
            withIntermediateDirectories: true,
            attributes: nil)
        FileManager.default.createFile(atPath: fileURL.path,
                                       contents: nil,
                                       attributes: nil)

        let fileHandle = try! FileHandle(forWritingTo: fileURL)
        file = BVHFile(empty: fileHandle)

        file.insertHierarchy(usingPhysic: physic, framerate: App.dae.refreshRate)
    }
}
