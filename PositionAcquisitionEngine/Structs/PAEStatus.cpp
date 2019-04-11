//
//  PAEStatus.cpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-04-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PAEStatus.h"

PAEStatus * PAEStatus_copy(PAEStatus * s)
{
	PAEStatus * c = new PAEStatus();

	strcpy(c->hostname, s->hostname);
	c->deviceCount = s->deviceCount;
	c->connectedDevices = (PAEDeviceStatus *)malloc(sizeof(PAEDeviceStatus) * c->deviceCount);

	for(int i = 0; i < c->deviceCount; ++i) {
		c->connectedDevices[i] = PAEDeviceStatus_copy(&(s->connectedDevices[i]));
	}

	return c;
}
