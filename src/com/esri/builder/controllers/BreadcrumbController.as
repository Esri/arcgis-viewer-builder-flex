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
package com.esri.builder.controllers
{

import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Breadcrumb;
import com.esri.builder.model.BreadcrumbModel;
import com.esri.builder.model.LocalizableBreadcrumb;
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.LogUtil;

import mx.logging.ILogger;
import mx.logging.Log;

public class BreadcrumbController
{
    private static const LOG:ILogger = LogUtil.createLogger(BreadcrumbController);

    private var lastBreadcrumbWasApp:Boolean;
    private var selectedBreadcrumb:Breadcrumb;

    public function BreadcrumbController()
    {
        AppEvent.addListener(AppEvent.APP_STATE_CHANGED, appStateChangedHandler, false, 0, true);
        AppEvent.addListener(AppEvent.BREADCRUMB_SELECTED, breadcrumbSelectedHandler, false, 0, true);

        AppEvent.addListener(AppEvent.CHANGES_SAVED, onChangesSaved, false, 0, true);
    }

    private function appStateChangedHandler(event:AppEvent):void
    {
        var appState:String = event.data as String;

        if (Log.isDebug())
        {
            LOG.debug("App state changed: {0}", appState);
        }

        //TODO: extract app states to constants
        switch (appState)
        {
            case "home":
            {
                removePreviousBreadcrumbIfHomeNotRoot();
                removePreviousBreadcrumbIfItIsApp();
                BreadcrumbModel.instance.addBreadcrumb(new LocalizableBreadcrumb("homeView.myApplications", appState));
                break;
            }
            case "settings":
            {
                removePreviousBreadcrumbIfItIsApp();
                BreadcrumbModel.instance.addBreadcrumb(new LocalizableBreadcrumb("homeView.settings", appState));
                break;
            }
            case "log":
            {
                BreadcrumbModel.instance.addBreadcrumb(new LocalizableBreadcrumb('viewer.log', appState));
                break;
            }
            case "viewer":
            {
                lastBreadcrumbWasApp = true;
                BreadcrumbModel.instance.addBreadcrumb(new Breadcrumb(Model.instance.appName));
                break;
            }
        }
    }

    private function removePreviousBreadcrumbIfHomeNotRoot():void
    {
        var willHomeBeRoot:Boolean = (BreadcrumbModel.instance.trail.length == 1);
        if (willHomeBeRoot)
        {
            BreadcrumbModel.instance.removeLastBreadcrumb();
        }
    }

    private function removePreviousBreadcrumbIfItIsApp():void
    {
        if (lastBreadcrumbWasApp)
        {
            BreadcrumbModel.instance.removeLastBreadcrumb();
            lastBreadcrumbWasApp = false;
        }
    }

    private function breadcrumbSelectedHandler(event:AppEvent):void
    {
        selectedBreadcrumb = event.data as Breadcrumb;
        changeAppState();
    }


    private function changeAppState():void
    {
        if (Log.isDebug())
        {
            LOG.debug("Change app state: {0}", selectedBreadcrumb.stateName);
        }

        // check for breadcrumb label
        if (selectedBreadcrumb.stateName == "home" && Model.instance.config.isDirty)
        {
            AppEvent.dispatch(AppEvent.SAVE_CHANGES, "breadcrumbtrail");
        }
        else
        {
            Model.instance.appState = selectedBreadcrumb.stateName;
        }
    }

    private function onChangesSaved(event:AppEvent):void
    {
        if (selectedBreadcrumb && event.data == "breadcrumbtrail")
        {
            Model.instance.appState = selectedBreadcrumb.stateName;
        }
    }
}
}
