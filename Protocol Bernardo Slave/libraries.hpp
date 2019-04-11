
//
//  libraries.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef libraries_hpp
#define libraries_hpp

#include <iostream>
#include <vector>
#include <algorithm>

#include <curses.h>

#include <PositionAcquisitionEngine/PositionAcquisitionEngine.hpp>
#include <PositionAcquisitionEngine/PAELinker.hpp>

using uint = unsigned int;
using keyCode = int;

#define FRAMERATE 15.0
#define FRAME_LENGTH 1.0 / FRAMERATE

#include "Core/App.hpp"

#include "UI/PBUI.hpp"

#endif /* libraries_hpp */
