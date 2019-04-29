//
//  PBView.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBView.hpp"
#include "Elements/PBControl.hpp"

PBPoint PBView::getGlobalPosition() {
    PBPoint pos = _frame.getPosition();

    if(_superview == nullptr) {
        return pos;
    }

    PBPoint superviewPos = _superview->getGlobalPosition();

    return pos + superviewPos;
}

void PBView::render() {
    // A base view does not draw anything itself, but tells its subviews to
    // draw themselves

    for (PBView * subview: _subviews) {
        if(subview->isHidden)
            continue;

        nC::clearStyling();
        
        subview->render();
    }
}

void PBView::addSubview(PBView * view) {
    // Set the view superview
    view->_superview = this;

    // Insert the view
    _subviews.push_back(view);
}

void PBView::removeFromSuperView() {
    _superview->removeSubview(this);
}

PBControl * PBView::getSelectedControl() {
    PBControl * self = dynamic_cast<PBControl *>(this);

    // Are we a PBControl ?
    if(self != nullptr) {
        // We are a PB Control, if we are selected, return self
        return self->isSelected() ? self : nullptr;
    }

    // We are not a PBControl, asks subviews for their selected control
    PBControl * control = nullptr;

    for(PBView * view: _subviews) {
        control = view->getSelectedControl();

        if(control != nullptr) {
            // The view has a selected control, return it
            return control;
        }
    }

    // No selected control found
    return nullptr;
}

void PBView::removeSubview(PBView * view) {
    // Set the view superview as nil
    view->_superview = nullptr;

    // And remove the view from the list
    _subviews.erase(std::remove(_subviews.begin(), _subviews.end(), view), _subviews.end());
}



PBView::~PBView() {
    for(PBView * subview: _subviews) {
        subview->removeFromSuperView();
        delete subview;
    }
}
