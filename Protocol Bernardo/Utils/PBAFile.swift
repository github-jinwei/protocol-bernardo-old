//
//  BVHFile.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-23.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import simd

/// Represent a Protocol Bernardo Animatic file (.pba)
///
/// PBA Files are built as an adapted version of the bvh file format.
/// It uses the same kind of hierarchy and frame storage, but ignore the
/// frame count value and uses quaternion to store the rotation instead of reverse
/// euler angles.
class PBAFile {
    /// The file handle to the pba file
    var handle: FileHandle

    /// Tell if the file has already been closed. You cannot add physics to a closed
    /// file
    private var _isClosed: Bool = false


    /// Tell if the file has already been closed. You cannot add physics to a closed
    /// file
    @inlinable var isClosed: Bool { return _isClosed }

    /// Create an empty BVA file using the given fileHandle
    ///
    /// - Parameter handle: <#handle description#>
    init(empty handle: FileHandle) {
        self.handle = handle
    }

    /// Append string to the file.
    ///
    /// - Parameter string: String to add
    private func append(_ string: String) {
        handle.write(string.data(using: .utf8)!)
    }

    /// Closes the file, preventing any more insertion to it
    func close() {
        guard !isClosed else { return }
        _isClosed = true

        // And close the file
        handle.closeFile()
    }

    deinit {
        close()
    }
}

// MARK: - Hierarchy
extension PBAFile {
    /// Insert the physic hierarchy inside the file.
    ///
    /// This must be called before any position is inserted inside the file
    ///
    /// - Parameters:
    ///   - physic: The physic to build the hierarchy for
    ///   - framerate: The framerate used for this recording
    func insertHierarchy(usingPhysic physic: PhysicalUser, framerate: UInt) {
        let offsets = getOffsets(ofPhysic: physic)

        let content = """
        HIERARCHY
        ROOT torso
        {
            OFFSET \(offsets[.torso]!.x) \(offsets[.torso]!.y) \(offsets[.torso]!.z)
            CHANNELS 7 Xposition Yposition Zposition Xrotation Yrotation Zrotation Wrotation
            JOINT neck
            {
                OFFSET \(offsets[.neck]!.x) \(offsets[.neck]!.y) \(offsets[.neck]!.z)
                CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                JOINT head
                {
                    OFFSET \(offsets[.head]!.x) \(offsets[.head]!.y) \(offsets[.head]!.z)
                    CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                    End Site
                    {
                        OFFSET 0.0 8.91 0.0
                    }
                }
                JOINT leftShoulder
                {
                    OFFSET \(offsets[.leftShoulder]!.x) \(offsets[.leftShoulder]!.y) \(offsets[.leftShoulder]!.z)
                    CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                    JOINT leftElbow
                    {
                        OFFSET \(offsets[.leftElbow]!.x) \(offsets[.leftElbow]!.y) \(offsets[.leftElbow]!.z)
                        CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                        JOINT leftHand
                        {
                            OFFSET \(offsets[.leftHand]!.x) \(offsets[.leftHand]!.y) \(offsets[.leftHand]!.z)
                            CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                            End Site
                            {
                                OFFSET -8.32 0.0 0.0
                            }
                        }
                    }
                }
                JOINT rightHand
                {
                    OFFSET \(offsets[.rightHand]!.x) \(offsets[.rightHand]!.y) \(offsets[.rightHand]!.z)
                    CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                    JOINT rightElbow
                    {
                        OFFSET \(offsets[.rightElbow]!.x) \(offsets[.rightElbow]!.y) \(offsets[.rightElbow]!.z)
                        CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                        JOINT rightHand
                        {
                            OFFSET \(offsets[.rightHand]!.x) \(offsets[.rightHand]!.y) \(offsets[.rightHand]!.z)
                            CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                            End Site
                            {
                                OFFSET 8.32 0.0 0.0
                            }
                        }
                    }
                }
            }
            JOINT leftHip
            {
                OFFSET \(offsets[.leftHip]!.x) \(offsets[.leftHip]!.y) \(offsets[.leftHip]!.z)
                CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                JOINT leftKnee
                {
                    OFFSET \(offsets[.leftKnee]!.x) \(offsets[.leftKnee]!.y) \(offsets[.leftKnee]!.z)
                    CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                    JOINT leftFoot
                    {
                        OFFSET \(offsets[.leftFoot]!.x) \(offsets[.leftFoot]!.y) \(offsets[.leftFoot]!.z)
                        CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                        End Site
                        {
                            OFFSET 0.0 0.0 8.91
                        }
                    }
                }
            }
            JOINT rightHip
            {
                OFFSET \(offsets[.rightHip]!.x) \(offsets[.rightHip]!.y) \(offsets[.rightHip]!.z)
                CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                JOINT rightKnee
                {
                    OFFSET \(offsets[.rightKnee]!.x) \(offsets[.rightKnee]!.y) \(offsets[.rightKnee]!.z)
                    CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                    JOINT rightFoot
                    {
                        OFFSET \(offsets[.rightFoot]!.x) \(offsets[.rightFoot]!.y) \(offsets[.rightFoot]!.z)
                        CHANNELS 4 Xrotation Yrotation Zrotation Wrotation
                        End Site
                        {
                            OFFSET 0.0 0.0 8.91
                        }
                    }
                }
            }
        }
        MOTION
        Framerate: \(framerate)
        """

        // Insert the hierarchy
        append(content)
    }

    /// Gets all the offeset between bones for the given positions. Offset are given for
    /// a T pose matchin the morphologie of the given physic
    ///
    /// - Parameter physic: The physic
    /// - Returns: All the offsets as vec3 in a dictionnary with their joints as key
    private func getOffsets(ofPhysic physic: PhysicalUser) -> [SkeletonJoint: vector_float3] {
        let skeleton = physic.skeleton

        var offsets = [SkeletonJoint: float3]()
        var offset: float3
        var distance: Float

        // TORSO
        offset = float3(0.0, 0.0, 0.0)
        offsets[.torso] = offset

        // NECK
        distance = abs(skeleton.torso.position.distance(from: skeleton.neck.position))
        offset = float3(0.0, distance, 0.0)
        offsets[.neck] = offset

        // HEAD
        distance = abs(skeleton.neck.position.distance(from: skeleton.head.position))
        offset = float3(0.0, distance, 0.0)
        offsets[.head] = offset

        // LEFT SHOULDER
        distance = abs(skeleton.neck.position.distance(from: skeleton.leftShoulder.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftShoulder] = offset

        // LEFT ELBOW
        distance = abs(skeleton.leftShoulder.position.distance(from: skeleton.leftElbow.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftElbow] = offset

        // LEFT HAND
        distance = abs(skeleton.leftElbow.position.distance(from: skeleton.leftHand.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftHand] = offset

        // RIGHT SHOULDER
        distance = abs(skeleton.neck.position.distance(from: skeleton.rightShoulder.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightShoulder] = offset

        // RIGHT ELBOW
        distance = abs(skeleton.rightShoulder.position.distance(from: skeleton.rightElbow.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightElbow] = offset

        // RIGHT HAND
        distance = abs(skeleton.rightElbow.position.distance(from: skeleton.rightHand.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightHand] = offset

        // LEFT HIP
        distance = abs(skeleton.torso.position.distance(from: skeleton.leftHip.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftHip] = offset

        // LEFT KNEE
        distance = abs(skeleton.leftHip.position.distance(from: skeleton.leftKnee.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.leftKnee] = offset

        // LEFT FOOT
        distance = abs(skeleton.leftKnee.position.distance(from: skeleton.leftFoot.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.leftFoot] = offset

        // RIGHT HIP
        distance = abs(skeleton.torso.position.distance(from: skeleton.rightHip.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightHip] = offset

        // RIGHT KNEE
        distance = abs(skeleton.rightHip.position.distance(from: skeleton.rightKnee.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.rightKnee] = offset

        // RIGHT FOOT
        distance = abs(skeleton.rightKnee.position.distance(from: skeleton.rightFoot.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.rightFoot] = offset

        return offsets
    }
}

// MARK: - Insertion
extension PBAFile {
    /// Insert the current position of the given physical user to the file.
    ///
    /// The user skeleton should be in the global reference system.
    ///
    /// - Parameter physic: The physic to add
    func insert(physic: PhysicalUser) {
        guard !isClosed else { return }

        // Build the line to insert
        let lineElements = buildLine(forPhysic: physic).map({ String($0) })
        let line = lineElements.joined(separator: " ")

        // Add the line
        append(line + "\n")
    }

    /// Create and format of elements representing the given physic, to be inserted in the pba
    ///
    /// - Parameter physic: The physic
    /// - Returns: All the elements in a Float array
    private func buildLine(forPhysic physic: PhysicalUser) -> [Float] {
        let torso = physic.skeleton.torso

        var elements = [torso.position.x, torso.position.y, torso.position.z]
        elements.append(contentsOf: physic.skeleton.jointsOrientation())

        return elements
    }
}
