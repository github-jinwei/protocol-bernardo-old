//
//  PBVerticalLine.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-02.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBVerticalLine_hpp
#define PBVerticalLine_hpp

#include "PBView.hpp"
#include "../utils/PBPoint.hpp"

class PBVerticalLine: public PBView {
public:
    PBVerticalLine(const PBPoint &aPosition, const uint &aLength);

    uint length;

    // MARK: - PBView
    void render();
};

#endif /* PBVerticalLine_hpp */
