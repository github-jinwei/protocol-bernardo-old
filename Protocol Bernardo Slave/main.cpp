//
//  main.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//
#include <time.h>

#include "main.hpp"

#include "Core/App.hpp"
#include "../PositionAcquisitionEngine/PositionAcquisitionEngine.hpp"

int main(int argc, const char * argv[]) {

    // Start the Position Acquisition Engine
    App->pae->start();

    while (true) {
        clock_t startTime = clock();

        doThings();

        candenceLoop(startTime);
    }


    return 0;
}

void doThings() {
    PAEStatus * status = App->pae->getStatus();

    if (status->deviceCount == 0) {
        App->pae->freeStatus(status);
        return;
    }

    DAEDeviceStatus * device = &(status->connectedDevices[0]);

    if (device->state == DEVICE_IDLE) {
        std::cout << "Connecting to device : " << device << std::endl;
        App->pae->connectToDevice(device->deviceSerial);
        App->pae->freeStatus(status);
        return;
    }

    if (device->state == DEVICE_READY) {
        std::cout << "Activating device : " << device << std::endl;
        App->pae->setDeviceActive(device->deviceSerial);
        App->pae->freeStatus(status);
        return;
    }

    App->pae->freeStatus(status);
}

void candenceLoop(const clock_t &loopStart) {
    clock_t loopTime = clock();

    float loopDuration = float(loopTime - loopStart) / CLOCKS_PER_SEC;

    // If the frame time is lower than the targeted length
    if (loopDuration < FRAME_LENGTH) {
        // Wait for the remaining time
        usleep((FRAME_LENGTH - loopDuration) * 1000);
    }
}
