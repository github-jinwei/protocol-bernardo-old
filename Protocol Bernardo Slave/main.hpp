//
//  main.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef main_h
#define main_h

#include "libraries.hpp"

void doThings();

/**
 Cadence the loop to the FRAME_LENGTH value

 @param loopStart The time the loop started
 */
void candenceLoop(const clock_t &loopStart);

#endif /* main_h */
