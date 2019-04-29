//
//  PBButton.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBButton.hpp"

PBButton::PBButton(const std::string &aTitle, const PBPoint &aPosition):
    PBView(PBFrame(aPosition, uint(aTitle.size() + 4), 3)) {
    titleLabel = new PBLabel(aTitle, PBPoint(2, 1));
    addSubview(titleLabel);
}

void PBButton::render() {
    nC::clearStyling();

    if (isSelected()) {
        nC::setBackground(COLOR_WHITE);
        nC::setForeground(COLOR_BLACK);
    }

    PBPoint globalPos = getGlobalPosition();
    PBFrame frame = getFrame();

    if(!isInline) {
        nC::box(globalPos.x, globalPos.y, frame.width, frame.height);
    }

    titleLabel->renderWithoutStyling();
}

