//
//  PBLabel.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBLabel.hpp"

PBLabel::PBLabel(const std::string &aTitle, const PBPoint &aPosition):
    position(aPosition),
    title(aTitle) {}

void PBLabel::renderWithoutStyling() {
    int posX = position.x;
    int posY = position.y;

    // Adjust the label position based on its alignement
    switch(alignement) {
        case LABEL_ALIGN_LEFT: break;
        case LABEL_ALIGN_CENTER: posX -= (title.size() / 2); break;
        case LABEL_ALIGN_RIGHT: posX -= title.size(); break;
    }

    nC::move(posX, posY);
    nC::print << title;
}

void PBLabel::render() {
    nC::clearStyling();

    renderWithoutStyling();

    PBView::render();
}
