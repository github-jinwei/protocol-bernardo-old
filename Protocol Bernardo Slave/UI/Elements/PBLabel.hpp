//
//  PBLabel.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBLabel_hpp
#define PBLabel_hpp

#include "PBView.hpp"

class PBLabel: public PBView {
public:
    PBLabel(const std::string &aTitle, const PBPoint &aPosition);

    PBPoint position;

    std::string title;

    enum Alignement {
        LABEL_ALIGN_LEFT,
        LABEL_ALIGN_CENTER,
        LABEL_ALIGN_RIGHT
    };

    Alignement alignement;

    void renderWithoutStyling();

    // MARK: - PBView
    void render();
};

#endif /* PBLabel_hpp */
