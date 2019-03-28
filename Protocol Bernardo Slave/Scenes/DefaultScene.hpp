//
//  DefaultScene.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DefaultScene_hpp
#define DefaultScene_hpp

#include "../UI/PBScene.hpp"

class PBVerticalMenu;

class WelcomeScene: public PBScene {
	void sceneWillAppear() override;

	private:
	PBVerticalMenu * menu;

	void openDevices();
};

#endif /* DefaultScene_hpp */
