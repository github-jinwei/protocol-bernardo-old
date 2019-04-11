//
//  maths.h
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-03-29.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef maths_h
#define maths_h

#ifdef __APPLE__
#    include <simd/simd.h>

#    define float2 simd_float2
#    define float3 simd_float3
#    define quatf simd_quatf
#else
#    include <Eigen/Dense>

#    define float2 Eigen::Vector2f
#    define float3 Eigen::Vector3f
#    define quatf Eigen::Quaternionf
#endif

#endif /* maths_h */
