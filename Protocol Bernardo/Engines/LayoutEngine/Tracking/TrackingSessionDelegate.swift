//
//  TrackingSessionDelegate.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-04-18.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation

protocol TrackingSessionDelegate: AnyObject {

	func sessionDidUpdate(_: TrackingSession)

	func session(_: TrackingSession, stoppedTrackingUser: User)
}
