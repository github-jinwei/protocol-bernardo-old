//
//  Socket.swift
//  dataflow-emitter
//
//  Created by Valentin Dufois on 03/12/2018.
//  Copyright © 2018 Prisme. All rights reserved.
//

import Foundation
import SwiftSocket

/// Represent a network socket, allowing for sending data to a remote socket
class TCPSocket {
	// MARK: Properties

	/// The socket client
	private var socket: TCPClient!

	/// Tell if the socket is connected
	private var isSocketConnected: Bool = false

	/// Current connection status of the socket. True if connected
	public var connected: Bool {
		return isSocketConnected
	}

	/// The socket url
	private var url: String!

	/// The socket port
	private var port: Int32!

	/// Open a connection
	///
	/// - Parameters:
	///   - url: URL of the socket
	///   - port: Port of the socket
	func connect(to url: String, port: Int32) {
		// Make sure the socket isn't already opened
		guard !self.connected else {
			print("[Socket.connect] Socket is already connected to \(socket.address):\(socket.port)")
			return
		}

		self.url = url
		self.port = port

		// Create the client
		socket = TCPClient(address: url, port: port)

		// Open the client and check for success or failure
		switch socket.connect(timeout: 10) {
		case .success:
			// Socket opened successfully
			isSocketConnected = true
            print("[SwiftSocket] Socket opened successfully")

		case .failure(let error):
			// Failed to open socket
			isSocketConnected = false
            print("[SwiftSocket] Socket failed to open : \(error.localizedDescription)")
		}
	}
	
	/// Emit the given data on the socket
	///
	/// - Parameter data: Data to send
	func emit(data: Data) {
		guard self.connected else {
			print("[Socket.emit] Socket is not connected")
			reconnect()
			return
		}

		switch socket.send(data: data) {
		case .success:
			_ = socket.send(string: "\n")

		case .failure(_):
			isSocketConnected = false
		}
	}

	/// Read from the socket. if no data can be read, this will return nil
	///
	/// - Parameter count: Number of bytes to read from the socket
	/// - Returns: The received data or nil if no data is present
	func read(count: Int) -> Data? {
		guard let bytes = socket.read(count) else { return nil }

		return Data(bytes)
	}

	/// Disconnect then reconnect the socket on the same url and port
	func reconnect() {
		// Close the current connection if any
		disconnect()

		// Open a new connection
		connect(to: url, port: port)
	}

	/// Disconnect from the socket. The socket be re-opened on the same url and port
	/// by calling `Socket.reconnect()`
	func disconnect() {
		guard self.connected else { return }

		socket.close()
		isSocketConnected = false
	}

	/// Make sure to properly close the connection
	deinit {
		disconnect()
	}
}
