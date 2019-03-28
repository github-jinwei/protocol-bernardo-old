//
//  PAELinker.hpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-03-16.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PAELinker_hpp
#define PAELinker_hpp

#include "libraries.h"

#include "Structs/PAEDeviceStatus.h"

/** Forward Declarations */
class PositionAcquisitionEngine;
struct PAEStatus;

class PAELinker {
public:
    void connect(const std::string &ip, const std::string &port, const bool &isSecure);

    inline void shouldReceive(const bool &shouldReceive) {
        _isReceiver = shouldReceive;
    }

    void send(PAEStatus * status);

    std::vector<PAEDeviceStatus> storedDevices();

	std::mutex receiverLock;

    ~PAELinker();

private:

    /** The socket io client */
    sio::client * _socket = nullptr;

    bool _isReceiver = false;

    bool _isConnected = false;

    std::map<std::string, PAEStatus *> _storedStatus;

    /**
     Builds a proper uri for the given ip and port using either http or https

     @param ip The IP of the URI
     @param port The port of the URI
     @param isSecure Tell if https should be used
     @return The compiled URI
     */
    std::string buildURI(const std::string &ip, const std::string &port, const bool &isSecure);

    /**
     Called everytime a new paeState has been received

     @param event The reception event
     */
    void onPaeStateReceived(const sio::event &event);

    sio::message::ptr transformPAEStatusToMessage(PAEStatus * status);
};

#endif /* PAELinker_hpp */
