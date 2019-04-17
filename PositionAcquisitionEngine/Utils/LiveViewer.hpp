//
//  LiveViewer.hpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-04-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef LiveViewer_hpp
#define LiveViewer_hpp

#include <map>

#include "../libraries.hpp"

struct PAEDeviceStatus;
struct Skeleton;

class LiveViewer {
public:

	/**
	 Display the tracked skeleton of the given device on the given frame.
	 If no viewer exist for the given device, this will create it.
	 The rgbFrame can be null, if this happened, the viewer will use a
	 512x424 black frame.

	 @param device The device's status
	 @param rgbFrame The device's frame
	 */
	void presentView(const PAEDeviceStatus * device, const openni::VideoFrameRef * rgbFrame);

	/**
	 Close the viewer for the given device

	 @param device The device to close the viewer
	 */
	void endViewer(const std::string &serial);

	/** Properly closes all viewers */
	~LiveViewer();

private:

	/** The list of opened windows identified by device's status */
	std::map<std::string, std::string> _windowList;

	/**
	 Get the window name for the given device

	 @param device A devicee
	 @return The device's window name (this does not imply the window exist)
	 */
	std::string getWindowName(const PAEDeviceStatus * device) const;

	/**
	 Prepare the device frame. If the frame is null, this will create a black image.
	 If the frame exist, it creates a copy of it.

	 @param frame A frame
	 @return The prepared frame
	 */
	cv::Mat prepareFrame(const openni::VideoFrameRef * rgbFrame) const;

	/**
	 Print the given skeleton joints on the given frame

	 @param skeleton The skeleton to print
	 @param rgbFrame The receiving frame
	 */
	void insertSkeleton(const ::Skeleton * skeleton, cv::Mat &frame) const;
};

#endif /* LiveViewer_hpp */
