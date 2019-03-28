//
//  PAELinker.cpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-03-16.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PAELinker.hpp"

#include "PositionAcquisitionEngine.hpp"
#include "Utils/sio.hpp"

void PAELinker::connect(const std::string &ip, const std::string &port, const bool &isSecure) {
    if(_isConnected) { return; }

    if(_socket != nullptr) {
        _socket->clear_con_listeners();
        _socket->clear_socket_listeners();
        delete _socket;
        _socket = nullptr;

        return; // Socket already connected, do nothing
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
        onPaeStateReceived(event);
    });

}

void PAELinker::send(PAEStatus * status) {
    if(!_isConnected) { return; }

    sio::message::ptr msg = PAEStatusToSioMessage(status);

    _socket->socket()->emit("paeState", msg);
}

std::vector<PAEDeviceStatus> PAELinker::storedDevices() {
    std::vector<PAEDeviceStatus> devices;

    std::map<std::string, PAEStatus *> * status = &_storedStatus;

    for(auto paeS: *status) {
        for(int i = 0; i < paeS.second->deviceCount; ++i) {
            try {
                devices.push_back(paeS.second->connectedDevices[i]);
            } catch(std::exception e) { }
        }
    }

    return devices;
}

PAELinker::~PAELinker() {
    for(auto i: _storedStatus) {
        PositionAcquisitionEngine::freeStatus(i.second);
    }
}

std::string PAELinker::buildURI(const std::string &ip, const std::string &port, const bool &isSecure) {

    std::string uri = (isSecure ? "http" : "https");
    uri += "://" + ip + ":" + port;

    return uri;
}

void PAELinker::onPaeStateReceived(const sio::event &event) {
    // Do nothing if we are not supposed to receive data
    if(!_isReceiver) { return; }

	// Lock the pae to prevent any race conditions
	this->receiverLock.lock();

    // treat the message to rebuild the received paestate
    sio::message::ptr mPtr = event.get_message();
    PAEStatus * foreignStatus = sioMessageToPAEStatus(&mPtr);

    // Integrate the status
    if(foreignStatus->deviceCount == 0) {
        // No device are attached to the receiveed state, ignore it
        PositionAcquisitionEngine::freeStatus(foreignStatus);
    }

	// Get the name of the host of the received status
    std::string hostname = foreignStatus->connectedDevices[0].deviceHostname;

    auto existingStatus = _storedStatus.find(hostname);
    if(existingStatus != _storedStatus.end()) {
        // Status already stored for this hostname, free it
        PositionAcquisitionEngine::freeStatus(existingStatus->second);
    }

    _storedStatus[hostname] = foreignStatus;

	this->receiverLock.unlock();
}
