//
//  PAELinker.hpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-03-16.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PAELinker_hpp
#define PAELinker_hpp

#include <map>
#include <mutex>

#include "libraries.hpp"

#include "Structs/PAEDeviceStatus.h"

/** Forward Declarations */
struct PAEStatus;
class PositionAcquisitionEngine;

/** The PAE linker is designed to work closely with the PositionAcquisitionEngine
 in the way that it directly transforms a PAEStatus to the appropriate format. */
class PAELinker {
public:
	inline void setPAE(PositionAcquisitionEngine * pae) { _pae = pae; }

    /**
     Open a connection with the adress at the specified ip and port. The PAE uses
	 websockets under the hood, meaning you can put a domain name as the ip.

	 For a server on the same machine, you can use localhost as the ip adress.

	 @param ip The server adress, can be an IP or a domain name. Must not containe "http://"
     @param port The port of the server, should not be empty
	 @param isSecure Tell if we should use 'http' or 'https'
     */
    void connect(const std::string &ip, const std::string &port, const bool &isSecure);

	void disconnect();

	inline bool isConnected() { return _isConnected; }

    /**
     Use this method to tell the linker if it should handle incoming data or if it
	 should discard it. The does not emit event, it is up to the user to call the
	 `storedDevices()`

     @param shouldReceive True if the linker should handle receiving messages
     */
    inline void shouldReceive(const bool &shouldReceive) {
        _isReceiver = shouldReceive;
    }

    /**
     Emit the given status to the server if the socket is connected

     @param status The status to emit
     */
	// TODO: Make this more universal
    void send(PAEStatus * status);

	void sendAction(const std::string &action, const std::string &deviceSerial);

    /**
     Gives the list of PAEStatus currently stored in the linker. The given status
	 is a copy and must be freed by yourself.
	 @discussion: Because this method is in a race-condition
	 with the received informations, it may block the thread until the current receiving
	 event has finished its work.


     @return A copy of all the received devices
     */
    std::vector<PAEStatus *> storedDevices();

    ~PAELinker();

private:
	PositionAcquisitionEngine * _pae;

    /** The socket io client */
    sio::client * _socket = nullptr;

	/** Tell if the linker should handle received information. If this is set to false
	 (it is by default), incoming messages will be discarded. */
    bool _isReceiver = false;

	/** Tell if the linker is currently connected to a server. */
	// TODO: Handle lost connection and reconnection
    bool _isConnected = false;

	/** All the status stored coming from distant machines. The `_receiverLock`
	 must be locked before reading or writing to this. */
    std::map<std::string, PAEStatus *> _storedStatus;

	/** Lock used to prevent race condition on the stored status */
	std::mutex _receiverLock;

    /**
     Builds a proper uri for the given ip and port using either http or https

     @param ip The IP of the URI
     @param port The port of the URI
     @param isSecure Tell if https should be used
     @return The compiled URI
     */
    std::string buildURI(const std::string &ip, const std::string &port, const bool &isSecure);

	/**
	 Called everytime a new message has been received

	 @param event The reception event
	 */
	void onReceived(const sio::event &event);

    /**
     Called everytime a new paeState has been received

     @param event The reception event
     */
    void onPaeStateReceived(const sio::event &event);

    /**
	 Gives a corresponding `sio::message` for the given `PAEStatus`. The given status
	 remains unchanged

     @param status The status to convert
     @return The corresponding sio message
     */
    sio::message::ptr transformPAEStatusToMessage(PAEStatus * status);
};

#endif /* PAELinker_hpp */
