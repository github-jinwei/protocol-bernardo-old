//
//  PBControl.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBControl_hpp
#define PBControl_hpp

#include "../PBView.hpp"

class PBControl: public PBView {
public:
    /** The top neighboor of this button */
    PBControl * topNeighboor;

    /** The right neighboor of this button */
    PBControl * rightNeighboor;

    /** The bottom neighboor of this button */
    PBControl * bottomNeighboor;

    /** The left neighboor of this button */
    PBControl * leftNeighboor;
    /**
     Tell if the button is selected

     @return True if selected, false otherwise
     */
    inline bool isSelected() { return _isSelected; }

    /**
     Tell the button to execute its action
     */
    void onKeyDown(const int &keyCode);

    /**
     Select the button, update its appearance
     */
    void select();

    /**
     Deselect the button, change is appearance
     */
    void deselect();

    /** The button's action */
    std::function<void(PBControl *)> action;

protected:
    bool _isSelected = false;

    void moveToNeighboor(PBControl * neighboor);
};

#endif /* PBControl_hpp */
