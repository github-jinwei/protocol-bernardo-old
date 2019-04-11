//
//  libraries.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-26.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef libraries_hpp
#define libraries_hpp

// C standard libraries
#include <stdio.h>
#include <unistd.h>
#include <limits.h>


// MARK: - MATHS
#include "maths.h"

// MARK: - OpenNI2/NiTE2
#ifdef __APPLE__
#    include <ni2/OpenNI.h>
#else
#    include <openni2/OpenNI.h>
#endif

#include <nite2/NiTE.h>

// MARK: - Socket IO
#include <socketio/sio_client.h>
#include <socketio/sio_socket.h>
#include <socketio/sio_message.h>

// MARK: - OpenCV
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


#endif /* libraries_hpp */
