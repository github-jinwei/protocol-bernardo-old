//
//  DefaultScene.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "DefaultScene.hpp"
#include "../UI/Elements.hpp"

DefaultScene::DefaultScene(const int argc, const char * argv[]) {
	// Parse args
	if(argc >= 2) {
		_ip = argv[1];
	}

	if(argc >= 3) {
		_port = argv[2];
	}

	if(argc >= 4) {
		if(std::string(argv[3]) == "liveview") {
			App->pae->enableLiveView();
		}
	}

	// Open the connection
	App->pae->shouldEmit(true);
	App->pae->linker()->connect(_ip, _port, _isSecure);
}

void DefaultScene::sceneWillAppear() {
	nC::clearWindow();

	// Build the scene

	// HEADER
	PBPoint pos = PBPoint(2, 1);
	PBLabel * titleLabel = new PBLabel("P R O T O C O L   B E R N A R D O   S L A V E", pos);
	titleLabel->isBold = true;
	getView()->addSubview(titleLabel);

	pos = PBPoint(0, 3);
	getView()->addSubview(new PBHorizontalLine(pos, nC::getWindowWidth()));

	// INFO BOXs

	pos = PBPoint(8, 9);
	PBBox * devicesBox = new PBBox(PBFrame(pos, 15, 5));

	_devicesCountLabel = new PBLabel("0", PBPoint(7, 2));
	_devicesCountLabel->alignement = PBLabel::LABEL_ALIGN_CENTER;
	_devicesCountLabel->isBold = true;
	devicesBox->addSubview(_devicesCountLabel);

	PBLabel * devicesLabel = new PBLabel(" Devices ", PBPoint(7, 4));
	devicesLabel->alignement = PBLabel::LABEL_ALIGN_CENTER;
	devicesBox->addSubview(devicesLabel);

	getView()->addSubview(devicesBox);


	pos = pos + PBPoint(25, 0);
	PBBox * usersBox = new PBBox(PBFrame(pos, 15, 5));

	_usersCountLabel = new PBLabel("0", PBPoint(7, 2));
	_usersCountLabel->alignement = PBLabel::LABEL_ALIGN_CENTER;
	_usersCountLabel->isBold = true;
	usersBox->addSubview(_usersCountLabel);

	PBLabel * usersLabel = new PBLabel(" Users ", PBPoint(7, 4));
	usersLabel->alignement = PBLabel::LABEL_ALIGN_CENTER;
	usersBox->addSubview(usersLabel);

	getView()->addSubview(usersBox);


	pos = pos + PBPoint(25, 0);
	PBBox * trackedUsersBox = new PBBox(PBFrame(pos, 15, 5));

	_trackedUsersCountLabel = new PBLabel("0", PBPoint(7, 2));
	_trackedUsersCountLabel->alignement = PBLabel::LABEL_ALIGN_CENTER;
	_trackedUsersCountLabel->isBold = true;
	trackedUsersBox->addSubview(_trackedUsersCountLabel);

	PBLabel * trackedUsersLabel = new PBLabel(" Tracked ", PBPoint(7, 4));
	trackedUsersLabel->alignement = PBLabel::LABEL_ALIGN_CENTER;
	trackedUsersBox->addSubview(trackedUsersLabel);

	getView()->addSubview(trackedUsersBox);

	PBLabel * serverLabel = new PBLabel("Server Status", PBPoint(2, nC::getWindowHeight() - 2));
	getView()->addSubview(serverLabel);

	_serverStatusLabel = new PBLabel("-", serverLabel->getFrame().getPosition() + PBPoint((int)serverLabel->getTitle().size() + 2, 0));
	_serverStatusLabel->isBold = true;
	getView()->addSubview(_serverStatusLabel);

	// Get the machine hostname
	char hostname[_POSIX_HOST_NAME_MAX + 1];
	hostname[_POSIX_HOST_NAME_MAX] = '\0';
	gethostname(hostname, _POSIX_HOST_NAME_MAX);

	PBLabel * machineNameLabel = new PBLabel(hostname, PBPoint(nC::getWindowWidth() - 2, nC::getWindowHeight() - 2));
	machineNameLabel->alignement = PBLabel::LABEL_ALIGN_RIGHT;
	getView()->addSubview(machineNameLabel);

	App->pae->start();
}

void DefaultScene::sceneWillRender() {
	PAEStatusCollection * statusCollection = App->pae->getStatus();

	PAEStatus * status;
	PAEDeviceStatus * device;
	PhysicalUser * user;

	int devicesCount = 0,
		usersCount = 0,
		trackedCount = 0;

	for(int i = 0; i < statusCollection->statusCount; ++i) {
		status = statusCollection->status[i];

		devicesCount += status->deviceCount;

		for(int j = 0; j < status->deviceCount; ++j) {
			device = &status->connectedDevices[j];

			// TODO: Do this via network
			switch(device->state) {
				case DEVICE_IDLE:
					App->pae->connectToDevice(device->deviceSerial);
					break;
				case DEVICE_READY:
					App->pae->activateDevice(device->deviceSerial);
					break;
				default: break;
			}

			usersCount += device->userCount;

			for(int k = 0; k < device->userCount; ++k) {
				user = &device->trackedUsers[k];

				if(user->state == USER_TRACKED) {
					++trackedCount;
				}
			}
		}
	}

	_devicesCountLabel->setTitle(std::to_string(devicesCount));
	_usersCountLabel->setTitle(std::to_string(usersCount));
	_trackedUsersCountLabel->setTitle(std::to_string(trackedCount));

	_serverStatusLabel->setTitle(App->pae->linker()->isConnected() ? "Connected" : "Not Connected");
}
