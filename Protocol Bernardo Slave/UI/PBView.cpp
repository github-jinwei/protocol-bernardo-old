//
//  PBView.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBView.hpp"

void PBView::render() {
    // A base view does not draw anything itself, but tells its subviews to
    // draw themselves

    for (PBView * subview: _subviews) {
        subview->render();
    }
}

void PBView::addSubview(PBView * view) {
    // Set the view superview
    view->_superview = this;

    // And insert the view
    _subviews.push_back(view);
}

void PBView::removeFromSuperView() {
    _superview->removeView(this);
}

void PBView::removeView(PBView * view) {
    // Set the view superview as nil
    view->_superview = nullptr;

    // And remove the view from the list
    _subviews.erase(std::remove(_subviews.begin(), _subviews.end(), view), _subviews.end());
}
