//
//  WbSockt.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-23.
//  Copyright © 2019 Prisme. All rights reserved.
//

import Foundation
import Starscream

class Socket {
    private var socket: WebSocket!

    func connect(to domain: String, port: Int32) {
        let url = URL(string: "http://\(domain):\(port)/")!

        socket = WebSocket(url: url)
        socket.delegate = self
        socket.connect()
    }

    func emit(data: Data) {

        socket.write(string: String(data: data, encoding: .utf8)!)
    }

    deinit {
        socket.disconnect()
    }
}

extension Socket: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("WebSocket connected")
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("WebSocket disconnected")
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {

    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {

    }
}
