//
//  PBButton.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBButton_hpp
#define PBButton_hpp

#include "PBControl.hpp"
#include "PBLabel.hpp"

class PBButton: public PBControl {
public:
    PBButton(const std::string &aTitle, const PBFrame &aFrame);

    /** The button's frame */
    PBFrame frame;

    /**
     Changes the button's title

     @param title The new title for the button
     */
    inline void setTitle(const std::string &title) { titleLabel->title = title; }

    /**
     Gives the current title of the button

     @return The button title
     */
    inline std::string getTitle() { return titleLabel->title; }

    // MARK: - PBView
    std::function<void(PBButton *)> action;

    // MARK: - PBView
    void render();

private:

    PBLabel * titleLabel;
};

#endif /* PBButton_hpp */
