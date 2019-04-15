//
//  Core.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include <unistd.h>

#include "Core.hpp"
#include "../UI/PBScene.hpp"
#include "../UI/PBView.hpp"
#include "../UI/Elements/PBControl.hpp"

void Core::init(PBScene * firstScene) {
	// Parse flags for connectivity
	std::string ip, port;

    nC::init();

    // Present the first scene
    presentScene(firstScene);
}

void Core::main() {
    clock_t loopStart;

    while (_isRunning) {
        loopStart = clock();

        // Catch user interactions
        catchInteractions();

        // Send it to the selected item of each scene
        propagateInteractions();

		// Raw clear the window every 5 seconds to limit artifacts and other fuckeries
		if(_loopCount % ((int)FRAMERATE * 5) == 0) {
			nC::rawClear();
		}

		// Completely clear the window content, everything is redrawn on each frame
		nC::clearWindow();
		
		// Clear any residual styling from the previous frame
		nC::clear();

        // Render each scene
        for(PBScene * scene: _scenes) {
            scene->render();
        }

		// Place the cursor at the bottom right of the window
        nC::mv(nC::getWindowWidth()-1, nC::getWindowHeight()-1);
        nC::print << " ";

        // Refresh the screen
        refresh();

		++_loopCount;

        // And cadence the loop
        candenceLoop(loopStart);
    }

    // Loop has ended, free all the scenes and their resources
    for(PBScene * scene: _scenes) {
        delete scene;
    }

    endwin();
}

void Core::presentScene(PBScene * scene) {
    // Ignore bad pointers
    if(scene == nullptr) {
        return;
    }

    // Tell the scene it is going to appear
    scene->sceneWillAppear();
    _scenes.push_back(scene);
}

void Core::removeScene(PBScene * scene) {
    _scenes.erase(std::remove(_scenes.begin(), _scenes.end(), scene), _scenes.end());
}

void Core::end() {
    _isRunning = false;
}

void Core::propagateInteractions() {
    // If no key are pressed, do nothing
    if(_pressedKeys.size() == 0) {
        return;
    }

    // For each scene
    for (PBScene * scene: _scenes) {
        PBControl * selectedControl = scene->getView()->getSelectedControl();

        if(selectedControl != nullptr) {
            selectedControl->onKeyPressed(_pressedKeys);
        }
    }
}

void Core::candenceLoop(const clock_t &loopStart) {
    clock_t loopTime = clock();

    float loopDuration = float(loopTime - loopStart) / CLOCKS_PER_SEC;

    // If the frame time is lower than the targeted length
    if (loopDuration < FRAME_LENGTH) {
        // Wait for the remaining time
        usleep((FRAME_LENGTH - loopDuration) * 1000);
    }
}

void Core::catchInteractions() {
    _pressedKeys.clear();

    int c = 0;

    while((c = getch()) != ERR)
    {
        if(c >= 65 && c <= 90)  //Treat caps as minuscules
            c += 32;

        _pressedKeys.push_back(c);
    }
}
