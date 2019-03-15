//
//  WelcomeScene.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "WelcomeScene.hpp"

#include "../UI/Elements.hpp"
#include "DevicesScene.hpp"

void WelcomeScene::sceneWillAppear() {
    nC::clearWindow();

    PBPoint pos = PBPoint(2 , 1);
    PBLabel * titleLabel = new PBLabel("P R O T O C O L   B E R N A R D O", pos);
    titleLabel->isBold = true;
    getView()->addSubview(titleLabel);

    pos = PBPoint(0, 3);
    getView()->addSubview(new PBHorizontalLine(pos, nC::getWindowWidth()));

    pos = PBPoint(3, 5);
    PBLabel * mainMenuLabel = new PBLabel("Main Menu", pos);
    mainMenuLabel->isBold = true;
    getView()->addSubview(mainMenuLabel);

    pos = PBPoint(1, 7);
    menu = new PBVerticalMenu(pos);
    menu->addItem("Devices", [this] (void *) { this->openDevices(); });
    menu->addItem(new PBMenuItem("Synchronization"));
    menu->addItem(new PBMenuItem("Automation"));
    menu->select(nullptr);

    getView()->addSubview(menu);
}

void WelcomeScene::openDevices() {
    App->core->presentScene(new DevicesScene());
    dismiss();
}
