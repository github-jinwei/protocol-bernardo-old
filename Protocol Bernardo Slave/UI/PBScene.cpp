//
//  PBScene.cpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#include "PBScene.hpp"
#include "PBView.hpp"

PBScene::PBScene(): PBScene(new PBView()) {}

PBScene::PBScene(PBView * aView):
    _view(aView) {}

void PBScene::render() {
    sceneWillRender();

    _view->render();

    sceneDidRender();
}

void PBScene::dismiss() {
    App->core->removeScene(this);
}

PBScene::~PBScene() {
    sceneWillUnload();

    delete _view;
}

void PBScene::sceneWillAppear() {}

void PBScene::sceneWillRender() {}

void PBScene::sceneDidRender() {}

void PBScene::sceneWillUnload() {}
