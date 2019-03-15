//
//  WelcomeScene.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef WelcomeScene_hpp
#define WelcomeScene_hpp

#include "PBScene.hpp"

class PBVerticalMenu;

class WelcomeScene: public PBScene {
    void sceneWillAppear() override;

private:
    PBVerticalMenu * menu;

    void openDevices();
};

#endif /* WelcomeScene_hpp */
