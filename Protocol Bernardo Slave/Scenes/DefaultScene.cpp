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
		_isSecure = std::string(argv[3]) == "secure";
	}

	// Open the connection
	App->pae->linker()->connect(_ip, _port, _isSecure);
}

void DefaultScene::sceneWillAppear() {
	nC::clearWindow();

	PBPoint pos = PBPoint(2 , 1);
	PBLabel * titleLabel = new PBLabel("P R O T O C O L   B E R N A R D O", pos);
	titleLabel->isBold = true;
	getView()->addSubview(titleLabel);

	pos = PBPoint(0, 3);
	getView()->addSubview(new PBHorizontalLine(pos, nC::getWindowWidth()));
}
