//
//  App.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef App_hpp
#define App_hpp

class PositionAcquisitionEngine;

class ApplicationObject {
public:
    ApplicationObject();

    PositionAcquisitionEngine * pae;
};

extern ApplicationObject * App;

#endif /* App_hpp */
