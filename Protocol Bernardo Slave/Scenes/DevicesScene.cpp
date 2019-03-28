//
//  DevicesScene.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-02.
//  Copyright © 2019 Prisme. All rights reserved.
//
#include <sstream>
#include <string>

#include "DevicesScene.hpp"

#include "../../PositionAcquisitionEngine/PositionAcquisitionEngine.hpp"
#include "../UI/Elements.hpp"
#include "WelcomeScene.hpp"

// MARK: - Lifecycle

void DevicesScene::sceneWillAppear() {

    nC::clearWindow();

    // Create the view Elements
    // Back button
    PBButton * backButton = new PBButton("< Back", PBPoint(0, 0));
    backButton->action = [this] (PBControl * btn) {
        App->core->presentScene(new WelcomeScene());
        this->dismiss();
    };
    backButton->isInline = true;

    // Screen title
    PBLabel * label = new PBLabel("D E V I C E S", PBPoint(24, 1));
    label->isBold = true;

    // Header separator
    PBHorizontalLine * hLine = new PBHorizontalLine(PBPoint(0, 3), nC::getWindowWidth());

    // Toggle pae button
    _togglePAEButton = new PBButton("Start PAE", PBPoint(0, 4));
    _togglePAEButton->isInline = true;
    _togglePAEButton->action = [this] (PBControl * sender) { this->toggleEngine(); };
    _togglePAEButton->select(nullptr);

    // Devices list
    _devicesList = new PBVerticalMenu(PBPoint(1, 7));
    _devicesList->emptyMessage = "No devices found";

    // Connect All Button
    PBButton * connectAllButton = new PBButton("Connect All", PBPoint(0, nC::getWindowHeight() - 3));
    connectAllButton->isInline = true;
    connectAllButton->action = [] (PBControl * sender) {
        App->pae->connectAllDevices();
    };

    // Activate all Button
    PBButton * activateAllButton = new PBButton("Activate All", PBPoint(14, nC::getWindowHeight() - 3));
    activateAllButton->isInline = true;
    activateAllButton->action = [] (PBControl * sender) {
        App->pae->activateAllDevices();
    };

    // Sidebar separator
    PBVerticalLine * vLine = new PBVerticalLine(PBPoint(30, 4), nC::getWindowHeight() - 3);

    // Connections between elements
    backButton->bottomNeighboor = _togglePAEButton;
    _togglePAEButton->topNeighboor = backButton;
    _togglePAEButton->bottomNeighboor = _devicesList;
    _devicesList->topNeighboor = _togglePAEButton;
    _devicesList->bottomNeighboor = connectAllButton;
    connectAllButton->topNeighboor = _devicesList;
    connectAllButton->rightNeighboor = activateAllButton;
    activateAllButton->leftNeighboor = connectAllButton;
    activateAllButton->topNeighboor = _devicesList;

    // Add them to the view
    getView()->addSubview(backButton);
    getView()->addSubview(label);
    getView()->addSubview(hLine);
    getView()->addSubview(_togglePAEButton);
    getView()->addSubview(_devicesList);
    getView()->addSubview(connectAllButton);
    getView()->addSubview(activateAllButton);
    getView()->addSubview(vLine);
}

void DevicesScene::sceneWillRender() {
    // Refresh the devices list
    PAEStatus * paeStatus = App->pae->getStatus();

    if(paeStatus->deviceCount != _devicesList->getItemsCount()) {
        fillDevicesList(paeStatus);

        _devicesList->isHidden = _devicesList->getItemsCount() == 0;
    }

    for(int i = 0; i < paeStatus->deviceCount; ++i) {
        PAEDeviceStatus device = paeStatus->connectedDevices[i];

        std::string label;

        switch (device.state) {
            case DEVICE_IDLE:       label = "idle"; break;
            case DEVICE_CONNECTING: label = "connecting"; break;
            case DEVICE_READY:      label = "ready"; break;
            case DEVICE_ACTIVE:     label = "active"; break;
            case DEVICE_CLOSING:    label = "closing"; break;
            case DEVICE_ERROR:      label = "error"; break;
            default: label = "unknown";
        }

        std::stringstream labelTitle;
        labelTitle << device.deviceSerial << " (" << label << ")";

        PBMenuItem * item = _devicesList->getItem(i);
        item->setTitle(labelTitle.str());
    }
}

// MARK: - Lists

void DevicesScene::fillDevicesList(PAEStatus * paeStatus) {
    _devicesList->removeAllItems();

    for(int i = 0; i < paeStatus->deviceCount; ++i) {
        PAEDeviceStatus device = paeStatus->connectedDevices[i];

        _devicesList->addItem(device.deviceName, [this] (PBMenuItem * item) {
            if(_selectedItem != nullptr) {
                _selectedItem->deselect();
            }

            _selectedItem = item;
            _selectedItem->select(_devicesList);

            std::string * serial = static_cast<std::string *>(item->value);
            this->displayDevice(*serial);
        }, device.deviceSerial);
    }
}

// MARK: - Actions

void DevicesScene::toggleEngine() {
    if(App->pae->isRunning()) {

        App->pae->stop();
        _togglePAEButton->setTitle("Start PAE");

        return;
    }

    App->pae->start();
    _togglePAEButton->setTitle("Stop PAE");
    nC::clearWindow();
}

void DevicesScene::displayDevice(const std::string &serial) {
    // Update interface to reflect current device
}
