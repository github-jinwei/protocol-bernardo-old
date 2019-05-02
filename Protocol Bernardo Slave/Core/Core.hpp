//
//  Core.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-28.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef Core_hpp
#define Core_hpp

#include "../libraries.hpp"

/** Forward declaration */
class PBScene;

class Core {
public:
    void init(PBScene * firstScene);

    /**
     The main loop used to execute and render the interface
     */
    void main();

    /**
     Add a new scene to the render loop. The given scene will be presented after
     all the currently presented scenes

     @param scene The new scene
     */
    void presentScene(PBScene * scene);

    /**
     Reemove the given scene from the render loop

     @param scene The scene to remove
     */
    void removeScene(PBScene * scene);

    /**
     Terminate the render loop, ending the application
     */
    void end();

private:
    bool _isRunning = true;

	unsigned long int _loopCount = 0;

    void candenceLoop(const clock_t &loopStart);

    std::vector<PBScene *> _scenes;

    void catchInteractions();
    void propagateInteractions();
    std::vector<keyCode> _pressedKeys;
};


#endif /* Core_hpp */
