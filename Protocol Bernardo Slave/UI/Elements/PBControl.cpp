//
//  PBControl.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBControl.hpp"

void PBControl::onKeyDown(const int &keyCode) {
    switch(keyCode) {
        case KEY_UP:    moveToNeighboor(   topNeighboor); break;
        case KEY_RIGHT: moveToNeighboor( rightNeighboor); break;
        case KEY_DOWN:  moveToNeighboor(bottomNeighboor); break;
        case KEY_LEFT:  moveToNeighboor(  leftNeighboor); break;
        case KEY_ENTER: action(this); break;
        default:
            return;
    }
}

void PBControl::select() {
    _isSelected = true;
}

void PBControl::deselect() {
    _isSelected = false;
}

void PBControl::moveToNeighboor(PBControl * neighboor) {
    if(topNeighboor != nullptr) {
        deselect();
        topNeighboor->select();
    }
}
