//
//  main.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//
#include <time.h>
#include <unistd.h>

#include "main.hpp"

#include "Core/App.hpp"
#include "Core/Core.hpp"

#include "Scenes/DefaultScene.hpp"

int main(int argc, const char * argv[]) {
    
    if(argc >= 2 && argv[argc-1] == "debug") {

     	App->pae->start();

     	while(true) {
     		doThings();
     	}
     	
     	return 0;
    }
      
    
    DefaultScene * defaultScene = new DefaultScene(argc, argv);
    App->core->init(defaultScene);
    
    App->core->main();
        
    return 0;
}

void doThings() {
    PAEStatusCollection * statusCollection = App->pae->getStatus();
    PAEStatus * status = statusCollection->status[0];

    if (status->deviceCount == 0) {
        std::cout << "Zero devices found" << std::endl;
        App->pae->freeStatus(status);
        return;
    }

    PAEDeviceStatus * device = &(status->connectedDevices[0]);

    if (device->state == DEVICE_IDLE) {
        std::cout << "Connecting to device : " << device << std::endl;
        App->pae->connectToDevice(device->deviceSerial);
        App->pae->freeStatus(status);
        return;
    }

    if (device->state == DEVICE_READY) {
        std::cout << "Activating device : " << device << std::endl;
        App->pae->activateDevice(device->deviceSerial);
        App->pae->freeStatus(status);
        return;
    }

    App->pae->freeCollection(statusCollection);
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
