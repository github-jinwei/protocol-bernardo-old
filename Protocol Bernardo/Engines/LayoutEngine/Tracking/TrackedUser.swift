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

    /// Unique UUID for this tracked user
    var uuid = UUID().uuidString

    /// The filename for this tracked user
    var fileName: String {
        return uuid + ".bvh"
    }

    /// The filewrapper holding the tracked user informations
    var wrapper: FileWrapper {
        let fileContent = makeBVHFileContent()
        return FileWrapper(regularFileWithContents: fileContent.data(using: .utf8)!)
    }

    /// List of all the motions stored in this file
    var motions = [Skeleton]()

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
        motions.append(physic.skeleton)
    }
}

extension TrackedUser {
    func makeBVHFileContent() -> String {
        var fileContent: String = ""

        guard motions.count > 0 else { return fileContent }

        fileContent += makeBVHHeader()
        fileContent += makeBVHMotions()

        return fileContent
    }

    private func makeBVHHeader() -> String {
        let offsets = getOffsets()

        return """
        HIERARCHY
        ROOT torso
        {
            OFFSET \(offsets[.torso]!.x) \(offsets[.torso]!.y) \(offsets[.torso]!.z)
            CHANNELS 6 Xposition Yposition Zposition Zrotation Xrotation Yrotation
            JOINT neck
            {
                OFFSET \(offsets[.neck]!.x) \(offsets[.neck]!.y) \(offsets[.neck]!.z)
                CHANNELS 3 Zrotation Xrotation Yrotation
                JOINT head
                {
                    OFFSET \(offsets[.head]!.x) \(offsets[.head]!.y) \(offsets[.head]!.z)
                    CHANNELS 3 Zrotation Xrotation Yrotation
                    End Site
                    {
                        OFFSET 0.0 8.91 0.0
                    }
                }
                JOINT leftShoulder
                {
                    OFFSET \(offsets[.leftShoulder]!.x) \(offsets[.leftShoulder]!.y) \(offsets[.leftShoulder]!.z)
                    CHANNELS 3 Zrotation Xrotation Yrotation
                    JOINT leftElbow
                    {
                        OFFSET \(offsets[.leftElbow]!.x) \(offsets[.leftElbow]!.y) \(offsets[.leftElbow]!.z)
                        CHANNELS 3 Zrotation Xrotation Yrotation
                        JOINT leftHand
                        {
                            OFFSET \(offsets[.leftHand]!.x) \(offsets[.leftHand]!.y) \(offsets[.leftHand]!.z)
                            CHANNELS 3 Zrotation Xrotation Yrotation
                            End Site
                            {
                                OFFSET -8.32 0.0 0.0
                            }
                        }
                    }
                }
                JOINT rightShoulder
                {
                    OFFSET \(offsets[.rightShoulder]!.x) \(offsets[.rightShoulder]!.y) \(offsets[.rightShoulder]!.z)
                    CHANNELS 3 Zrotation Xrotation Yrotation
                    JOINT rightElbow
                    {
                        OFFSET \(offsets[.rightElbow]!.x) \(offsets[.rightElbow]!.y) \(offsets[.rightElbow]!.z)
                        CHANNELS 3 Zrotation Xrotation Yrotation
                        JOINT rightHand
                        {
                            OFFSET \(offsets[.rightHand]!.x) \(offsets[.rightHand]!.y) \(offsets[.rightHand]!.z)
                            CHANNELS 3 Zrotation Xrotation Yrotation
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
                CHANNELS 3 Zrotation Xrotation Yrotation
                JOINT leftKnee
                {
                    OFFSET \(offsets[.leftKnee]!.x) \(offsets[.leftKnee]!.y) \(offsets[.leftKnee]!.z)
                    CHANNELS 3 Zrotation Xrotation Yrotation
                    JOINT leftFoot
                    {
                        OFFSET \(offsets[.leftFoot]!.x) \(offsets[.leftFoot]!.y) \(offsets[.leftFoot]!.z)
                        CHANNELS 3 Zrotation Xrotation Yrotation
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
                CHANNELS 3 Zrotation Xrotation Yrotation
                JOINT rightKnee
                {
                    OFFSET \(offsets[.rightKnee]!.x) \(offsets[.rightKnee]!.y) \(offsets[.rightKnee]!.z)
                    CHANNELS 3 Zrotation Xrotation Yrotation
                    JOINT rightFoot
                    {
                        OFFSET \(offsets[.rightFoot]!.x) \(offsets[.rightFoot]!.y) \(offsets[.rightFoot]!.z)
                        CHANNELS 3 Zrotation Xrotation Yrotation
                        End Site
                        {
                            OFFSET 0.0 0.0 8.91
                        }
                    }
                }
            }
        }
        MOTION
        Frames: \(motions.count)
        Frame Time: \(1.0 / Float(App.dae.refreshRate))
        
        """
    }

    private func makeBVHMotions() -> String {
        var content: String = ""

        for skeleton in motions {

            // Build the line to insert
            let lineElements = buildMotionLine(forSkeleton: skeleton).map({ String($0) })
            let line = lineElements.joined(separator: " ")

            content += line + "\n"
        }

        return content
    }

    /// Gets all the offeset between bones for the given positions. Offset are given for
    /// a T pose matchin the morphologie of the given physic
    ///
    /// - Parameter physic: The physic
    /// - Returns: All the offsets as vec3 in a dictionnary with their joints as key
    private func getOffsets() -> [SkeletonJoint: vector_float3] {
        var offsets = [SkeletonJoint: float3]()
        var offset: float3
        var distance: Float

        let skeleton = motions.randomElement()!

        // TORSO
        offset = float3(0.0, 0.0, 0.0)
        offsets[.torso] = offset

        // NECK
        distance = abs(simd_distance(skeleton.torso.position, skeleton.neck.position))
        offset = float3(0.0, distance, 0.0)
        offsets[.neck] = offset

        // HEAD
        distance = abs(simd_distance(skeleton.neck.position, skeleton.head.position))
        offset = float3(0.0, distance, 0.0)
        offsets[.head] = offset

        // LEFT SHOULDER
        distance = abs(simd_distance(skeleton.neck.position, skeleton.leftShoulder.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftShoulder] = offset

        // LEFT ELBOW
        distance = abs(simd_distance(skeleton.leftShoulder.position, skeleton.leftElbow.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftElbow] = offset

        // LEFT HAND
        distance = abs(simd_distance(skeleton.leftElbow.position, skeleton.leftHand.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftHand] = offset

        // RIGHT SHOULDER
        distance = abs(simd_distance(skeleton.neck.position, skeleton.rightShoulder.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightShoulder] = offset

        // RIGHT ELBOW
        distance = abs(simd_distance(skeleton.rightShoulder.position, skeleton.rightElbow.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightElbow] = offset

        // RIGHT HAND
        distance = abs(simd_distance(skeleton.rightElbow.position, skeleton.rightHand.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightHand] = offset

        // LEFT HIP
        distance = abs(simd_distance(skeleton.torso.position, skeleton.leftHip.position))
        offset = float3(-distance, 0.0, 0.0)
        offsets[.leftHip] = offset

        // LEFT KNEE
        distance = abs(simd_distance(skeleton.leftHip.position, skeleton.leftKnee.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.leftKnee] = offset

        // LEFT FOOT
        distance = abs(simd_distance(skeleton.leftKnee.position, skeleton.leftFoot.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.leftFoot] = offset

        // RIGHT HIP
        distance = abs(simd_distance(skeleton.torso.position, skeleton.rightHip.position))
        offset = float3(distance, 0.0, 0.0)
        offsets[.rightHip] = offset

        // RIGHT KNEE
        distance = abs(simd_distance(skeleton.rightHip.position, skeleton.rightKnee.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.rightKnee] = offset

        // RIGHT FOOT
        distance = abs(simd_distance(skeleton.rightKnee.position, skeleton.rightFoot.position))
        offset = float3(0.0, -distance, 0.0)
        offsets[.rightFoot] = offset

        // mm to cm (bvh uses centimeters)
        offsets = offsets.mapValues({ $0 / 10.0 })

        return offsets
    }

    /// Create and format elements representing the given physic, to be inserted in the pba
    ///
    /// - Parameter physic: The physic
    /// - Returns: All the elements in a Float array
    private func buildMotionLine(forSkeleton skeleton: Skeleton) -> [Float] {
        let torso = skeleton.torso

        // Add the skeleton informations
        var elements = [torso.position.x / 10.0, torso.position.y / 10.0, torso.position.z / 10.0]

        // Get all the joints rotation as relative euleur angles to their parent joint
        for jointID in SkeletonJoint.allCases {
            let jointQuaternion = skeleton[jointID].orientation
            let parentQuaternion = simd_inverse(getParentOrientation(forJoint: jointID, onSkeleton: skeleton))

            // Get the orientation delta
            let relQuaternion = jointQuaternion * parentQuaternion

            // Convert the quaternion to euler
            let euler = quaternionToEuler(relQuaternion)

            // append the joint euler angles to the list of motion parameters
            elements.append(contentsOf: [rad2deg(euler.z), rad2deg(euler.x), rad2deg(euler.y)])
        }

        return elements.map({ $0.isNaN ? 0.0 : $0 })
    }

    /// Gives the orientation of the specified joint relative to its parent joint orientation
    ///
    /// - Parameters:
    ///   - jointID: ID of the joint to work with
    ///   - skeleton: Skeleton to work with
    /// - Returns: The relative orientation of the specified joint
    private func getParentOrientation(forJoint jointID: SkeletonJoint, onSkeleton skeleton: Skeleton) -> simd_quatf {
        if jointID == .torso {
            return simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0)
        }

        return skeleton[jointID.parent].orientation
    }
}
