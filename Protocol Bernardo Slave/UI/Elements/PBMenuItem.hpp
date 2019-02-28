//
//  PBMenuItem.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBMenuItem_hpp
#define PBMenuItem_hpp

#include "PBUI.hpp"
#include "PBButton.hpp"

class PBMenuItem: public PBButton {
    // MARK: - PBButton

    /** Button's action */
    void click();

    std::function<void(PBMenuItem)> action;

    // MARK: - PBView
    void render();
};

#endif /* PBMenuItem_hpp */
