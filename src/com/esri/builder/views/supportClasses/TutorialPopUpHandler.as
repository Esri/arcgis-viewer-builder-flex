////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2013 Esri. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
////////////////////////////////////////////////////////////////////////////////
package com.esri.builder.views.supportClasses
{

import com.esri.builder.controllers.supportClasses.Settings;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.views.popups.TutorialPopUp;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;

public class TutorialPopUpHandler
{
    public static const MAPS:String = 'maps';
    public static const WIDGETS:String = 'widgets';
    public static const LAYOUT:String = 'layout';
    public static const DESIGN:String = 'design';

    private var currentShownTutorialName:String;

    public var xOffset:Number = 0;
    public var yOffset:Number = 0;

    public function showTutorialPopUp(tutorialName:String):void
    {
        var shouldShowPopUp:Boolean = Model.instance.isTutorialModeEnabled;
        if (!shouldShowPopUp)
        {
            return;
        }

        currentShownTutorialName = tutorialName;
        var tutorialPopUp:TutorialPopUp = createTutorialPopUpByName(tutorialName);
        tutorialPopUp.addEventListener(CloseEvent.CLOSE, tutorialPopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(tutorialPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(tutorialPopUp);
        offsetPopUp(tutorialPopUp);
    }

    private function createTutorialPopUpByName(tutorialName:String):TutorialPopUp
    {
        var tutorialPopUp:TutorialPopUp = new TutorialPopUp();

        switch (tutorialName)
        {
            case MAPS:
            {
                tutorialPopUp.contentTitle = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.mapsContentTitle');
                tutorialPopUp.content = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.mapsContent');
                tutorialPopUp.linkURL = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.mapsLinkURL');
                tutorialPopUp.linkLabel = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.mapsLinkLabel');
                break;
            }
            case WIDGETS:
            {
                tutorialPopUp.contentTitle = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.widgetsContentTitle');
                tutorialPopUp.content = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.widgetsContent');
                tutorialPopUp.linkURL = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.widgetsLinkURL');
                tutorialPopUp.linkLabel = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.widgetsLinkLabel');
                break;
            }
            case LAYOUT:
            {
                tutorialPopUp.contentTitle = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.layoutContentTitle');
                tutorialPopUp.content = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.layoutContent');
                tutorialPopUp.linkURL = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.layoutLinkURL');
                tutorialPopUp.linkLabel = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.layoutLinkLabel');
                break;
            }
            case DESIGN:
            {
                tutorialPopUp.contentTitle = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.designContentTitle');
                tutorialPopUp.content = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.designContent');
                tutorialPopUp.linkURL = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.designLinkURL');
                tutorialPopUp.linkLabel = ResourceManager.getInstance().getString('BuilderStrings', 'gettingStartedPopUp.designLinkLabel');
                break;
            }
        }

        return tutorialPopUp
    }

    private function tutorialPopUp_closeHandler(event:CloseEvent):void
    {
        var tutorialPopUp:TutorialPopUp = event.currentTarget as TutorialPopUp;
        updateTutorialModeEnabled(!tutorialPopUp.doNotShowAgain);
        tutorialPopUp.removeEventListener(CloseEvent.CLOSE, tutorialPopUp_closeHandler);
        PopUpManager.removePopUp(event.currentTarget as TutorialPopUp);
        tutorialPopUp = null;
    }

    private function updateTutorialModeEnabled(isEnabled:Boolean):void
    {
        var settings:Settings = Model.instance.exportSettings();
        settings.isTutorialModeEnabled = isEnabled;
        Model.instance.importSettings(settings);
        AppEvent.dispatch(AppEvent.TUTORIAL_MODE_SETTINGS_CHANGED);
    }

    private function offsetPopUp(tutorialPopUp:TutorialPopUp):void
    {
        tutorialPopUp.x += xOffset;
        tutorialPopUp.y += yOffset;
    }
}
}
