//
//  PBBox.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-04-15.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBBox_hpp
#define PBBox_hpp

#include "../PBView.hpp"
#include "../utils/PBPoint.hpp"

class PBBox: public PBView {
public:
	PBBox(const PBPoint &aPosition): PBView(PBFrame(aPosition, 1, 1)) {}

	PBBox(const PBFrame &aFrame): PBView(aFrame) {}

	void render() override;
};

#endif /* PBBox_hpp */
