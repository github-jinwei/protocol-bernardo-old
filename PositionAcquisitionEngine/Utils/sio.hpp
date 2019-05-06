//
//  sio.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-17.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef sio_h
#define sio_h

#include "../libraries.hpp"

#include "../Structs/PAEStatus.h"

sio::message::ptr float3ToSioMessage(const float3 &f) {
    sio::message::ptr mPtr = sio::array_message::create();
    sio::array_message * m = static_cast<sio::array_message *>(mPtr.get());

#ifdef __APPLE__
    m->push(sio::double_message::create(double(f.x)));
    m->push(sio::double_message::create(double(f.y)));
    m->push(sio::double_message::create(double(f.z)));
#else
    m->push(sio::double_message::create(double(f(0))));
    m->push(sio::double_message::create(double(f(1))));
    m->push(sio::double_message::create(double(f(2))));
#endif


    return mPtr;
}

float3 sioMessageToFloat3(const sio::message::ptr &mPtr) {
    std::vector<sio::message::ptr> m = mPtr->get_vector();
    float3 f;

#ifdef __APPLE__
    f.x = float(m[0]->get_double());
    f.y = float(m[1]->get_double());
    f.z = float(m[2]->get_double());
#else
    f(0) = float(m[0]->get_double());
    f(1) = float(m[1]->get_double());
    f(2) = float(m[2]->get_double());
#endif

    return f;
}

sio::message::ptr quatfToSioMessage(const quatf &q) {
    sio::message::ptr mPtr = sio::array_message::create();
    sio::array_message * m = static_cast<sio::array_message *>(mPtr.get());

#ifdef __APPLE__
    m->push(sio::double_message::create(double(q.vector.x)));
    m->push(sio::double_message::create(double(q.vector.y)));
    m->push(sio::double_message::create(double(q.vector.z)));
    m->push(sio::double_message::create(double(q.vector.w)));
#else
    m->push(sio::double_message::create(double(q.coeffs()(0))));
    m->push(sio::double_message::create(double(q.coeffs()(1))));
    m->push(sio::double_message::create(double(q.coeffs()(2))));
    m->push(sio::double_message::create(double(q.coeffs()(3))));
#endif

    return mPtr;
}

quatf sioMessageToQuatf(const sio::message::ptr &mPtr) {
    std::vector<sio::message::ptr> m = mPtr->get_vector();
    quatf q;

#ifdef __APPLE__
    q.vector.x = float(m[0]->get_double());
    q.vector.y = float(m[1]->get_double());
    q.vector.z = float(m[2]->get_double());
    q.vector.w = float(m[3]->get_double());
#else
    q.coeffs()(0) = float(m[0]->get_double());
    q.coeffs()(1) = float(m[1]->get_double());
    q.coeffs()(2) = float(m[2]->get_double());
    q.coeffs()(3) = float(m[3]->get_double());
#endif

    return q;
}

sio::message::ptr jointToSioMessage(const Joint * j) {
    sio::message::ptr mPtr = sio::object_message::create();
    sio::object_message * m = static_cast<sio::object_message *>(mPtr.get());

    m->insert("orientation", quatfToSioMessage(j->orientation));
    m->insert("orientationConfidence", sio::double_message::create(j->orientationConfidence));
    m->insert("position", float3ToSioMessage(j->position));
    m->insert("positionConfidence", sio::double_message::create(j->positionConfidence));

    return mPtr;
}

Joint sioMessageToJoint(const sio::message::ptr &mPtr) {
    std::map<std::string, sio::message::ptr> m = mPtr->get_map();
    Joint j;

    j.orientation = sioMessageToQuatf(m["orientation"]);
    j.orientationConfidence = float(m["orientationConfidence"]->get_double());
    j.position = sioMessageToFloat3(m["position"]);
    j.positionConfidence = float(m["positionConfidence"]->get_double());

    return j;
}

sio::message::ptr skeletonToSioMessage(const Skeleton * s) {
    sio::message::ptr mPtr = sio::object_message::create();
    sio::object_message * m = static_cast<sio::object_message *>(mPtr.get());

    m->insert("head", jointToSioMessage(&(s->head)));
    m->insert("neck", jointToSioMessage(&(s->neck)));
    m->insert("leftShoulder", jointToSioMessage(&(s->leftShoulder)));
    m->insert("rightShoulder", jointToSioMessage(&(s->rightShoulder)));
    m->insert("leftElbow", jointToSioMessage(&(s->leftElbow)));
    m->insert("rightElbow", jointToSioMessage(&(s->rightElbow)));
    m->insert("leftHand", jointToSioMessage(&(s->leftHand)));
    m->insert("rightHand", jointToSioMessage(&(s->rightHand)));
    m->insert("torso", jointToSioMessage(&(s->torso)));
    m->insert("leftHip", jointToSioMessage(&(s->leftHip)));
    m->insert("rightHip", jointToSioMessage(&(s->rightHip)));
    m->insert("leftKnee", jointToSioMessage(&(s->leftKnee)));
    m->insert("rightKnee", jointToSioMessage(&(s->rightKnee)));
    m->insert("leftFoot", jointToSioMessage(&(s->leftFoot)));
    m->insert("rightFoot", jointToSioMessage(&(s->rightFoot)));

    return mPtr;
}

Skeleton sioMessageToSkeleton(const sio::message::ptr &mPtr) {
    std::map<std::string, sio::message::ptr> m = mPtr->get_map();
    Skeleton s;

    s.head = sioMessageToJoint(m["head"]);
    s.neck = sioMessageToJoint(m["neck"]);
    s.leftShoulder = sioMessageToJoint(m["leftShoulder"]);
    s.rightShoulder = sioMessageToJoint(m["rightShoulder"]);
    s.leftElbow = sioMessageToJoint(m["leftElbow"]);
    s.rightElbow = sioMessageToJoint(m["rightElbow"]);
    s.leftHand = sioMessageToJoint(m["leftHand"]);
    s.rightHand = sioMessageToJoint(m["rightHand"]);
    s.torso = sioMessageToJoint(m["torso"]);
    s.leftHip = sioMessageToJoint(m["leftHip"]);
    s.rightHip = sioMessageToJoint(m["rightHip"]);
    s.leftKnee = sioMessageToJoint(m["leftKnee"]);
    s.rightKnee = sioMessageToJoint(m["rightKnee"]);
    s.leftFoot = sioMessageToJoint(m["leftFoot"]);
    s.rightFoot = sioMessageToJoint(m["rightFoot"]);

    return s;
}

sio::message::ptr PAEStatusToSioMessage(const PAEStatus * s) {
    sio::message::ptr msgPtr = sio::object_message::create();
    sio::object_message * msg = static_cast<sio::object_message *>(msgPtr.get());

	sio::message::ptr listPtr = sio::array_message::create();
	sio::array_message * list = static_cast<sio::array_message *>(listPtr.get());

	msg->insert("hostname", s->hostname);
	msg->insert("devices", listPtr);

    for(int i = 0; i < s->deviceCount; ++i) {
        PAEDeviceStatus * device = &(s->connectedDevices[i]);

        // Create the message
        sio::message::ptr deviceMessagePtr = sio::object_message::create();
        sio::object_message * deviceMessage = static_cast<sio::object_message *>(deviceMessagePtr.get());

        // Fill it
        deviceMessage->insert("deviceName", device->deviceName);
        deviceMessage->insert("deviceSerial", device->deviceSerial);
        deviceMessage->insert("state", sio::int_message::create(device->state));
        deviceMessage->insert("userCount", sio::int_message::create(device->userCount));

        sio::message::ptr trackedUsersPtr = sio::array_message::create();
        sio::array_message * trackedUsers = static_cast<sio::array_message *>(trackedUsersPtr.get());

        // Insert each tracked user
        for(int j = 0; j < device->userCount; ++j) {
            PhysicalUser * user = &(device->trackedUsers[j]);

            sio::message::ptr userMessagePtr = sio::object_message::create();
            sio::object_message * userMessage = static_cast<sio::object_message *>(userMessagePtr.get());

            userMessage->insert("userID", sio::int_message::create(user->userID));
            userMessage->insert("frame", sio::int_message::create(user->frame));
            userMessage->insert("state", sio::int_message::create(user->state));
            userMessage->insert("skeleton", skeletonToSioMessage(&(user->skeleton)));
            userMessage->insert("centerOfMass", float3ToSioMessage(user->centerOfMass));

            trackedUsers->push(userMessagePtr);
        }

        deviceMessage->insert("trackedUsers", trackedUsersPtr);

        // Insert the device in the message
        list->push(deviceMessagePtr);
    }

    return msgPtr;
}

PAEStatus * sioMessageToPAEStatus(const sio::message::ptr * mPtr) {
	std::map<std::string, sio::message::ptr> m = mPtr->get()->get_map();

    PAEStatus * status = new PAEStatus();
	strcpy(status->hostname, m["hostname"]->get_string().c_str());

	// The list of devices
	std::vector<sio::message::ptr> l = m["devices"]->get_vector();
    status->deviceCount = (unsigned int)l.size();
    status->connectedDevices = (PAEDeviceStatus *)malloc(sizeof(PAEDeviceStatus) * status->deviceCount);

    for(int i = 0; i < status->deviceCount; ++i) {
        std::map<std::string, sio::message::ptr> d = l[i]->get_map();

        PAEDeviceStatus device;
        strcpy(device.deviceName, d["deviceName"]->get_string().c_str());
        strcpy(device.deviceSerial, d["deviceSerial"]->get_string().c_str());

        switch (d["state"]->get_int()) {
            case 0: device.state = DEVICE_UNKNOWN; break;
            case 1: device.state = DEVICE_ERROR; break;
            case 2: device.state = DEVICE_IDLE; break;
            case 3: device.state = DEVICE_CONNECTING; break;
            case 4: device.state = DEVICE_READY; break;
            case 5: device.state = DEVICE_ACTIVE; break;
            case 6: device.state = DEVICE_CLOSING; break;
        }

        std::vector<sio::message::ptr> usersPtr = d["trackedUsers"]->get_vector();

        device.userCount = (unsigned int)usersPtr.size();
        device.trackedUsers = (PhysicalUser *)malloc(sizeof(PhysicalUser) * device.userCount);

        for(int j = 0; j < device.userCount; ++j) {
            std::map<std::string, sio::message::ptr> u = usersPtr[j]->get_map();

            PhysicalUser user;
            user.userID = u["userID"]->get_int();
            user.frame = (unsigned int)u["frame"]->get_int();

            switch (u["state"]->get_int()) {
                case 10: user.state = USER_ERRORED; break;
                case 11: user.state = USER_NO_SKELETON; break;
                case 12: user.state = USER_CALIBRATING; break;
                case 13: user.state = USER_TRACKED; break;
                case 14: user.state = USER_MISSING; break;
            }

            user.skeleton = sioMessageToSkeleton(u["skeleton"]);
            user.centerOfMass = sioMessageToFloat3(u["centerOfMass"]);

            device.trackedUsers[j] = user;
        }

        status->connectedDevices[i] = device;
    }

    return status;
}


#endif /* sio_h */
