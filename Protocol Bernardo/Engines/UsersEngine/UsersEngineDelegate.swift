//
//  UsersEngineDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-22.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol UsersEngineDelegate: AnyObject {
    /// Tells the delegate the engine has started tracking a new user
    ///
    /// - Parameters:
    ///   - engine: The emitting UsersEngine
    ///   - startedTrackingUser: The user the engine just started tracking. This
    /// user will not have any physic, do not try to access the latest and first physic properties, you have to wait for a `userEngine(_:user:physicUpdated:)` to get the first physic of the user
    func userEngine(_ engine: UsersEngine, startedTrackingUser: User)

    /// Tells the delegate the user's physic has been updated
    ///
    /// - Parameters:
    ///   - engine: The emitting UsersEngine
    ///   - user: THe User who's physic has been updated
    ///   - physicUpdated: The new physic of the user
    func userEngine(_ engine: UsersEngine, user: User, physicUpdated: PhysicalUser)

    /// Tells the delegate two users have been merged.
    ///
    /// - Parameters:
    ///   - engine: The emitting UsersEngine
    ///   - mergedUser: The user who's been merged inside the first one
    ///   - withUser: The user inside which the first one is merging
    func userEngine(_ engine: UsersEngine, mergedUser: User, inUser: User)

    /// Tells the delegate the engine is not tracking the user anymore.
    ///
    /// - Parameters:
    ///   - engine: The emitting UsersEngine
    ///   - stoppedTrackingUser: The users who will not be tracked anymore
    func userEngine(_ engine: UsersEngine, stoppedTrackingUser: User)

    /// Asks the delegate how many physics should be kept in history
    ///
    /// - Parameter engine: The engine asking
    /// - Returns: The number of physics to keep in history
    func usersPhysicsHistorySize(_ engine: UsersEngine) -> UInt
}
