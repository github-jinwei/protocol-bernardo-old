//
//  TrackedUser.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-23.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

/// A tracked user holds a BVA file containing a series of movements performed
/// by a user
class TrackedUser {
    /// The user tracked
    weak var user: User?

    /// The filename for this tracked user
    var fileName: String

    /// The filewrapper holding the tracked user informations
    var wrapper: FileWrapper {
        let fileContent = makeBVHFileContent()
        return FileWrapper(regularFileWithContents: fileContent)
    }

    /// List of all the motions stored in this file
    var motions = [Skeleton]()

    var lastFrame: UInt32 = 0

    /// Init and set the user being tracked
    ///
    /// - Parameter user: The user being tracked
    init(forUser user: User) {
        self.user = user
        fileName = [Calendar.current.component(.year, from: Date()),
                    Calendar.current.component(.month, from: Date()),
                    Calendar.current.component(.day, from: Date()),
                    Calendar.current.component(.hour, from: Date()),
                    Calendar.current.component(.minute, from: Date()),
                    Calendar.current.component(.second, from: Date()),
                    Calendar.current.component(.nanosecond, from: Date())].map { String($0) }.joined(separator: ".") + ".pba"
    }
}

// MARK: - Insertions
extension TrackedUser {
    /// Record the given physic in the file
    ///
    /// - Parameter physic: The physic to insert
    func add(physic: PhysicalUser) {
        guard physic.frame != lastFrame else { return }

        motions.append(physic.skeleton)
        lastFrame = physic.frame
    }
}

extension TrackedUser {
    func makeBVHFileContent() -> Data {
        if motions.isEmpty { return Data() }

        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
        encoder.nonConformingFloatEncodingStrategy = .convertToString(positiveInfinity: "\(CGFloat.greatestFiniteMagnitude)",
                                                                      negativeInfinity: "\(CGFloat.leastNormalMagnitude)",
                                                                      nan: "0.0")
        let data = try! encoder.encode(motions)

        return data
    }

}
