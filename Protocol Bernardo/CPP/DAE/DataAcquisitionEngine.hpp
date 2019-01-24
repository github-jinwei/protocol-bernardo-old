//
//  DataAcquisitionEngine.hpp
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-01-20.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef DataAcquisitionEngine_hpp
#define DataAcquisitionEngine_hpp

#include <map>

#include "DAEStatus.h"
#include "Kinect.hpp"

class DataAcquisitionEngine {
    static DataAcquisitionEngine * _instance;
    
public:
    
    static DataAcquisitionEngine * getInstance() {
        if(!_instance)
            _instance = new DataAcquisitionEngine();
        
        return _instance;
    };
    
    /**
     Holds a loop continuously checking for frame coming from the kinects
     */
    void main();
    
    /**
     Parse for any new kinects connected
     */
    void parseForKinects();
    
    /**
     Open the connection with the kinect specified

     @param serial Serial number of the Kinect to connect to
     */
    void connectToKinect(const std::string &serial);
    
    /**
     Activate the kinect, effectively startint to stream from it

     @param serial Serial number of the Kinect
     */
    void setKinectActive(const std::string &serial);
    
    /**
     Stops streaming fron the Kinect. Streaming can be resumed if needed

     @param serial Serial number of the kinect
     */
    void setKinectIdle(const std::string &serial);
    
    /**
     Gets the status of all kinects

     @return The global status
     */
    DAEStatus * getStatus();
    
    ~DataAcquisitionEngine();
    
private:
    DataAcquisitionEngine() {}
    
    bool _running = true;
    
    std::map<std::string, Kinect *> _kinects;
};

#endif /* DataAcquisitionEngine_hpp */
