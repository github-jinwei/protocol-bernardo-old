//
//  UsersEngine.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-09.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

/// The users engine receives raw user informations from the dae and uses the
/// currently opened layout and calibration profile to track users and replace
/// them all in the same coordinates system
class UsersEngine {
    // ////////////////
    // MARK: Properties
    
    internal var _users = [User]()
    
    /// The layout used to position the devices
    weak var layout: Layout?
    
    /// The calibration profile used to track users
    weak var profile: LayoutCalibrationProfile?
    
    // //////////////////
    // MARK: - Lifecycle
    
    /// Init
    init() {
        // Start by making ourselves an observer of the DAE
        App.dae.addObsever(self)
    }
    
    
    deinit {
        App.dae.removeObserver(self)
    }
}

extension UsersEngine: DataAcquisitionEngineObserver {
    func dae(_ dae: DataAcquisitionEngine, devicesStatusUpdated devices: [String: DeviceStatus]) {
        // Parse all the available users and store them correctly
        devices.forEach { serial, device in
            device.users.forEach { physicalUser in
                // Start by making sure this user is fully tracked
                guard physicalUser.state == USER_TRACKED else {
                    removePhysicFromUserIfNeeded(serial: serial, userID: physicalUser.userID)
                    return
                }
                
                // Are we already tracking this user ?
                if let user = self.user(forDeviceSerial: serial, andUserID: physicalUser.userID) {
                    // This users is already being tracked, just update its physic for the current device
                    user.trackedPhysics[serial] = physicalUser
                    return
                }
                
                // This user is not registered yet, let's find if its a redundancy of an already tracked user
                
                // Get the user center of mass in the global coordinates system
                let userCOM = profile!.device(forSerial: serial)!.globalCoordinates(forPosition: physicalUser.centerOfMass)
                
                // Find the user the closest from this point
                let (closest, distance) = closestUser(fromPosition: userCOM)
                
                guard closest != nil && distance < 150 else {
                    // No user where found, or was too far, create a new user
                    newUser(forPhysic: physicalUser, onDevice: serial)
                    return
                }
                
                // We have a match, insert ourselves
                closest?.devices[serial] = physicalUser.userID
                closest?.trackedPhysics[serial] = physicalUser
            }
        }
        
        // Sometimes, the devices give bad first position, resulting in separate User for the same real user.
        // To prevent this, let's do a swipe of all the tracked users,
        // if two of them are within close distance, we merge them in the first user
        
        // Make sure there is at least one other user
        guard _users.count > 1 else { return }
        
        _users.forEach { user in
            let closestUsers = usersByDistance(fromPosition: user.calibratedPosition)
            // If the current user is the first one in the array (like 99% of the time), select the second one
            let closest = closestUsers[0] === user ? closestUsers[1] : closestUsers[0]
            let distance = closest.calibratedPosition.distance(from: user.calibratedPosition)
            
            print(distance)
            
            if distance < 150 {
                // The two user are really close by, let's merge them
                closest.trackedPhysics.forEach { serial, physic in
                    user.devices[serial] = physic.userID
                    user.trackedPhysics[serial] = physic
                }
                
                // Remove the closest user from the user array
                _users.removeAll { $0 === closest }
            }
        }
    }
    
//    /// Compare the given physical user with already tracked users to find if it is already tracked
//    ///
//    /// - Parameter physicalUser: <#physicalUser description#>
//    /// - Returns: <#return value description#>
//    internal func getSameUser(forPhysicalUser physicalUser: PhysicalUser) -> User? {
//
//    }
    
    func newUser(forPhysic physic: PhysicalUser, onDevice serial: String) {
        let user = User()
        user.devices[serial] = physic.userID
        user.trackedPhysics[serial] = physic
        user.calibrationProfile = profile
    
        _users.append(user)
    }
    
    func removePhysicFromUserIfNeeded(serial: String, userID: Int16) {
        guard let user = self.user(forDeviceSerial: serial, andUserID: userID) else { return }
        
        // the device isn't actively tracking the user, remove everything
        user.trackedPhysics.removeValue(forKey: serial)
        user.devices.removeValue(forKey: serial)
        
        // if the user tracked anymore, remove it
        if user.trackedPhysics.count == 0 {
            _users.removeAll { $0 === user }
        }
    }
}


// MARK: - Accessing the tracked users
extension UsersEngine {
    var allUsers: [User] { return _users }
    
    /// Gets the closes user from the given position.
    ///
    /// - Parameter position: The position to gets the distance from
    /// - Returns: Tuple : (User found (might be nil), distance from the user (infinity if no user))
    func closestUser(fromPosition position: Position) -> (User?, Float) {
        let users = usersByDistance(fromPosition: position)
        
        guard users.count > 0 else { return (nil, Float.infinity) }
        
        // return a tuple with the closest user and its distance from the given position
        return (users[0], position.distance(from: users[0].calibratedPosition))
    }
    
    /// Returns an array of all the users ordered by their distance from the given position.
    /// The first users in the array are the closes
    ///
    /// - Parameter position: Reference position
    /// - Returns: The distance-ordered user array
    func usersByDistance(fromPosition position: Position) -> [User] {
        // Get a copy of the users array
        let users = _users
        
        // Get the distance for each user
        let distances = users.map {
            return position.distance(from: $0.calibratedPosition)
        }
        // Sort the array
        return zip(users, distances).sorted(by: { $0.1 < $1.1 }).map { $0.0 }
    }
    
    func users(forDeviceSerial serial: String) -> [User] {
        return _users.filter { user in user.devices[serial] != nil }
    }
    
    func user(forDeviceSerial serial: String, andUserID userID: Int16) -> User? {
        let foundUsers = _users.filter { user in
            // Is this user tracked by the specified device ?
            guard user.devices[serial] != nil else { return false }
            
            // Is this the correct user ?
            return user.devices[serial]! == userID
        }
        
        return foundUsers.count > 0 ? foundUsers[0] : nil
    }
}