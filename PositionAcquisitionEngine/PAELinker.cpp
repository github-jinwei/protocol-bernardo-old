//
//  PAELinker.cpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-03-16.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include <iostream>

#include "PAELinker.hpp"

#include "PositionAcquisitionEngine.hpp"
#include "Utils/sio.hpp"

void PAELinker::connect(const std::string &ip, const std::string &port, const bool &isSecure) {
    if(_isConnected || _socket != nullptr) {
		disconnect();
	}

    std::string uri = buildURI(ip, port, isSecure);

    _socket = new sio::client();
    _socket->connect(uri);

    // Set up events listeners
    _socket->set_open_listener([this] () {
        std::cout << "Socket opened" << std::endl;
        _isConnected = true;
    });

    _socket->set_fail_listener([this] () {
        std::cout << "Socket failed" << std::endl;
        _isConnected = false;
    });

    _socket->set_reconnecting_listener([this] () {
        _isConnected = false;
        std::cout << "Socket reconnecting" << std::endl;
    });
	_socket->set_reconnect_attempts(1);

    _socket->set_close_listener([this, uri] (sio::client::close_reason const& reason) {
        switch (reason) {
            case sio::client::close_reason::close_reason_normal:
                std::cout << "Socket properly closed" << std::endl;
                break;
            case sio::client::close_reason::close_reason_drop:
                std::cout << "Socket connection dropped" << std::endl;
                _socket->connect(uri);
                break;
        }

        _isConnected = false;
    });

    _socket->socket()->on("paeState", [this] (const sio::event &event) {
        onReceived(event);
    });
}

void PAELinker::disconnect() {
	if(!_isConnected) { return; }

	_isConnected = false;

	_socket->clear_con_listeners();
	_socket->clear_socket_listeners();
	_socket->close();
	delete _socket;
	_socket = nullptr;
}

void PAELinker::send(PAEStatus * status) {
    if(!_isConnected) { return; }

    sio::message::ptr msg = PAEStatusToSioMessage(status);

    _socket->socket()->emit("paeState", msg);
}

void PAELinker::sendAction(const std::string &action, const std::string &deviceSerial) {
	sio::message::ptr msg = sio::string_message::create(deviceSerial);
	_socket->socket()->emit(action, msg);
}

std::vector<PAEStatus *> PAELinker::storedDevices() {
	// Create the list of devices to give to the caller.
	std::vector<PAEStatus *> statusList;

	// Prevent race condition on the stored status lsit
	_receiverLock.lock();

	for(auto it = _storedStatus.begin(); it != _storedStatus.end(); ++it) {
		statusList.push_back(PAEStatus_copy(it->second));
	}

	// Unlock the list
	_receiverLock.unlock();

    return statusList;
}

PAELinker::~PAELinker() {
	disconnect();

    for(auto i: _storedStatus) {
        PositionAcquisitionEngine::freeStatus(i.second);
    }
}

std::string PAELinker::buildURI(const std::string &ip, const std::string &port, const bool &isSecure) {
    std::string uri = (isSecure ? "http" : "https");
    uri += "://" + ip + ":" + port;

    return uri;
}

void PAELinker::onReceived(const sio::event &event) {
	// Do nothing if we are not supposed to receive data
	if(!_isReceiver) { return; }

	std::string messageName = event.get_name();

	if(messageName == "paeState") {
		onPaeStateReceived(event);
		return;
	}

	if(messageName == "connectDevice") {
		std::string deviceSerial = event.get_message()->get_string();
		_pae->connectToDevice(deviceSerial);
	}

	if(messageName == "activateDevice") {
		std::string deviceSerial = event.get_message()->get_string();
		_pae->activateDevice(deviceSerial);
	}

	if(messageName == "deactivateDevice") {
		std::string deviceSerial = event.get_message()->get_string();
		_pae->deactivateDevice(deviceSerial);
	}
}

void PAELinker::onPaeStateReceived(const sio::event &event) {
	// Lock the pae to prevent any race conditions
	_receiverLock.lock();

    // treat the message to rebuild the received paestate
    sio::message::ptr mPtr = event.get_message();
    PAEStatus * foreignStatus = sioMessageToPAEStatus(&mPtr);

    // Integrate the status
    if(foreignStatus->deviceCount == 0) {
        // No device are attached to the received state, ignore it
        PositionAcquisitionEngine::freeStatus(foreignStatus);
		return;
    }

	// Get the name of the host of the received status
    std::string hostname = foreignStatus->hostname;

    auto existingStatus = _storedStatus.find(hostname);
    if(existingStatus != _storedStatus.end()) {
        // Status already stored for this hostname, free it
        PositionAcquisitionEngine::freeStatus(existingStatus->second);
    }

    _storedStatus[hostname] = foreignStatus;

	_receiverLock.unlock();
}
