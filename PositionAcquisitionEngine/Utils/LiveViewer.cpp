//
//  LiveViewer.cpp
//  PositionAcquisitionEngine
//
//  Created by Valentin Dufois on 2019-04-01.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "LiveViewer.hpp"

#include "../Structs/PAEDeviceStatus.h"
#include "../Structs/PhysicalUser.h"
#include "../Structs/Skeleton.h"

void LiveViewer::presentView(const PAEDeviceStatus * device, const openni::VideoFrameRef * rgbFrame) {
	// Make sure the device is usable
	if(device == nullptr)
		return;

	if(device->state != DEVICE_ACTIVE)
		return;

	// Get the window name
	std::string windowName;
	auto it = _windowList.find(device->deviceSerial);

	if(it == _windowList.end()) {
		windowName = getWindowName(device);
		cv::namedWindow(windowName);
	} else {
		windowName = it->second;
	}

	// Prepare thee frame
	cv::Mat frame = prepareFrame(rgbFrame);

	// Print the skeletons
	for(int i = 0; i < device->userCount; ++i) {
		insertSkeleton(&(device->trackedUsers[i].skeleton), frame);
	}

	// Update the window
	cv::imshow(windowName, frame);
}

void LiveViewer::endViewer(const std::string &serial) {
	auto it = _windowList.find(serial);

	if(it == _windowList.end()) {
		// The window does not exist
		return;
	}

	// Close the window
	cv::destroyWindow(it->second);
	_windowList.erase(it->first);
}

cv::Mat LiveViewer::prepareFrame(const openni::VideoFrameRef * rgbFrame) const {
	if(rgbFrame == nullptr || rgbFrame->getData() == nullptr) {
		return cv::Mat(512, 424, CV_8UC3, cv::Scalar(0,0,0));
	}

	// Convert openni frame to `cv::Mat`
	cv::Mat cImageBGR;
	const cv::Mat mImageRGB(rgbFrame->getHeight(),
							rgbFrame->getWidth(),
							CV_8UC3,
							(void*)rgbFrame->getData());
	cv::cvtColor(mImageRGB, cImageBGR, cv::COLOR_RGB2BGR);
	
	return cImageBGR;
}

void LiveViewer::insertSkeleton(const ::Skeleton * skeleton, cv::Mat &frame) const {
	Joint aJoints[15];
	aJoints[ 0] = skeleton->head;
	aJoints[ 1] = skeleton->neck;
	aJoints[ 2] = skeleton->leftShoulder;
	aJoints[ 3] = skeleton->rightShoulder;
	aJoints[ 4] = skeleton->leftElbow;
	aJoints[ 5] = skeleton->rightElbow;
	aJoints[ 6] = skeleton->leftHand;
	aJoints[ 7] = skeleton->rightHand;
	aJoints[ 8] = skeleton->torso;
	aJoints[ 9] = skeleton->leftHip;
	aJoints[10] = skeleton->rightHip;
	aJoints[11] = skeleton->leftKnee;
	aJoints[12] = skeleton->rightKnee;
	aJoints[13] = skeleton->leftFoot;
	aJoints[14] = skeleton->rightFoot;

	cv::Point2f aPoint[15];
	for( int s = 0; s < 15; ++ s )
	{
#ifdef __APPLE__
		aPoint[s].x = aJoints[s].position2D.x;
		aPoint[s].y = aJoints[s].position2D.y;
#else
		aPoint[s].x = aJoints[s].position2D(0);
		aPoint[s].y = aJoints[s].position2D(1);
#endif

		aPoint[s].x = frame.cols - aPoint[s].x;
	}

	cv::line(frame, aPoint[ 0], aPoint[ 1], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 1], aPoint[ 2], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 1], aPoint[ 3], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 2], aPoint[ 4], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 3], aPoint[ 5], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 4], aPoint[ 6], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 5], aPoint[ 7], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 1], aPoint[ 8], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 8], aPoint[ 9], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 8], aPoint[10], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[ 9], aPoint[11], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[10], aPoint[12], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[11], aPoint[13], cv::Scalar( 255, 0, 0 ), 3 );
	cv::line(frame, aPoint[12], aPoint[14], cv::Scalar( 255, 0, 0 ), 3 );

	for(int s = 0; s < 15; ++s)
	{
		if(aJoints[s].positionConfidence < 0.5 )
			cv::circle(frame, aPoint[s], 3, cv::Scalar(0, 0, 255), 2);
		else
			cv::circle(frame, aPoint[s], 3, cv::Scalar(0, 255, 0), 2);
	}
}

std::string LiveViewer::getWindowName(const PAEDeviceStatus * device) const {
	std::string windowName = device->deviceSerial;
	windowName += " - ";
	windowName += device->deviceName;

	return windowName;
}

LiveViewer::~LiveViewer() {
	// Close all windows
	for(std::pair<std::string, std::string> it: _windowList) {
		cv::destroyWindow(it.second);
		_windowList.erase(it.first);
	}
}
