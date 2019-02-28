//
//  PBButton.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBButton.hpp"

PBButton::PBButton(const std::string &aTitle, const PBFrame &aFrame):
    frame(aFrame) {
    titleLabel = new PBLabel(aTitle, PBPoint(frame.x, frame.y));
    addSubview(titleLabel);
}

void PBButton::render() {
    nC::clearStyling();

    if (isSelected()) {
        nC::setBackground(COLOR_WHITE);
        nC::setForeground(COLOR_BLACK);
    }

    nC::box(frame.x, frame.y, frame.width, frame.height);
    titleLabel->renderWithoutStyling();
}
