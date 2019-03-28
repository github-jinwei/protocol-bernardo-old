//
//  PBScene.hpp
//  Protocol Bernardo Slave
//
//  Created by Valentin Dufois on 2019-02-27.
//  Copyright © 2019 Prisme. All rights reserved.
//

#ifndef PBScene_hpp
#define PBScene_hpp

#include "../Core/Core.hpp"

class PBView;

/** A PBScene is used to display a view on the screen.
 If a view can be contained in another view, a scene is needed to display the root
 view. A Scene takes care of dispatching user events to the currently selected PBControl.

 You should subclass PBScene and use its four events methods: `sceneWillAppear()`,
 `sceneWillRender()`, `sceneDidRender()`, `sceneWillUnload()` to execute your own code.

 A scene is responsible for the view it is holding, and will free its contained views
 when being free-ed.

 Interaction between elements of different scenes, and between scenes themselves,
 should be kept to a strict minimum.

 To remove a view, call `dismiss()`, this will reemove the view from the render
 loop and free its content.
 */
class PBScene {
public:
    /** Create a scene with an empty view */
    PBScene();

    /** Create a scene and present the given view

    @param view The view to display
    */
    PBScene(PBView * view);

    /**
     Replace the currently presented view by the given one

     @param view The view to display
     */
    void presentView(PBView * view);

    /**
     Gives the view currently presented by this scene

     @return The presented view
     */
    inline PBView * getView() { return _view; }

    /**
     Remove the scene from the render loop
     */
    void dismiss();

    /** This will also free the entire view hierarchy hold by this scene.
     `sceneWillUnload()` is called right before freeing everything.
     */
    virtual ~PBScene();

protected:
    /**
     Called when the view was just created, should be used to setup elements of the view.
     */
    virtual void sceneWillAppear();

    /**
     Called everytime the view is about to render, should be used to perform updates
     before rendering. This is called after events have been sent.
     Another scene may have already rendered its content when this method is called
     */
    virtual void sceneWillRender();

    /**
     Called everytime the view just rendered, should be used for post render operation.
     Other scene may still have to render their content
     */
    virtual void sceneDidRender();

    /**
     Called when the scene is about to be freed. This is usually called when the scene is removed from the render loop
     The contained view and its subviews are automatically freed by the scene
     after this method.
     */
    virtual void sceneWillUnload();

private:
    /** The view presented by this scene */
    PBView * _view;

    /**
     Render the scene and its content on the screen
     */
    void render();

    /** The core has the right to access a scene private properties */
    friend Core;
};

#endif /* PBScene_hpp */
