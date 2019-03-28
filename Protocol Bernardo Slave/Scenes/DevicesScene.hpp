//
//  DevicesScene.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DevicesScene_hpp
#define DevicesScene_hpp

#include "../UI/PBScene.hpp"

/** Forward declaration */
class PBVerticalMenu;
class PBMenuItem;
class PBButton;
struct PAEStatus;

class DevicesScene: public PBScene {
    void sceneWillAppear() override;
    void sceneWillRender() override;

private:
    PBButton * _togglePAEButton;
    PBVerticalMenu * _devicesList;

    PBMenuItem * _selectedItem = nullptr;

    void fillDevicesList(PAEStatus * paeStatus);

    void toggleEngine();

    void displayDevice(const std::string &serial);
};

#endif /* DevicesScene_hpp */
