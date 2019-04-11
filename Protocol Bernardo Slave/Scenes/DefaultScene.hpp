//
//  DefaultScene.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DefaultScene_hpp
#define DefaultScene_hpp

#include "../libraries.hpp"
#include "../UI/PBScene.hpp"

class DefaultScene: public PBScene {
public:
	DefaultScene(const int argc, const char * argv[]);

	void sceneWillAppear() override;

private:
	// INTERFACE



	// LOGIC

	std::string _ip = "localhost";

	std::string _port = "5000";

	bool _isSecure = false;
};


#endif /* DefaultScene_hpp */
