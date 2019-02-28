//
//  PBView.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBView_hpp
#define PBView_hpp

#include "PBUI.hpp"

class PBView {
public:
    /**
     Tell the view to render itself and its subviews on the screen.
     Views are rendered in the same order they were added, with the current view
     beeing the first.
     */
    virtual void render();

    /**
     Add a child view to this view

     @param view The view to add as a child
     */
    void addSubview(PBView * view);

    /**
     Remove the current view from its parent view, this does not free the view
     */
    void removeFromSuperView();

protected:

    /** The view holding this view, might be nil */
    PBView * _superview;

    /** THe list of subviews */
    std::vector<PBView *> _subviews;

    /**
     Remove the given view from the list of subviews. This does not free the view

     @param view The view to remove
     */
    void removeView(PBView * view);
};

#endif /* PBView_hpp */
