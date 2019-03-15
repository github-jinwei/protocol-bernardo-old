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
#include "../utils/PBPoint.hpp"

class PBLabel: public PBView {
public:
    PBLabel(const std::string &aTitle, const PBPoint &aPosition);

    inline std::string getTitle() { return _title; }

    inline void setTitle(const std::string &title) {
        _title = title;
    }

    enum Alignement {
        LABEL_ALIGN_LEFT,
        LABEL_ALIGN_CENTER,
        LABEL_ALIGN_RIGHT
    };

    Alignement alignement;

    bool isBold = false;

    bool isUnderlined = false;

    void renderWithoutStyling();

    // MARK: - PBView
    void render() override;

private:
    std::string _title;
};

#endif /* PBLabel_hpp */
