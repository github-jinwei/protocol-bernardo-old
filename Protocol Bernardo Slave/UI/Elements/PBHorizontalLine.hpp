//
//  PBHorizontalLine.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-03-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBHorizontalLine_hpp
#define PBHorizontalLine_hpp

#include "../PBView.hpp"
#include "../utils/PBPoint.hpp"

class PBHorizontalLine: public PBView {
public:
    PBHorizontalLine(const PBPoint &aPosition, const uint &aLength);

    uint length;

    // MARK: - PBView
    void render();
};

#endif /* PBHorizontalLine_hpp */
