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

import com.esri.builder.controllers.supportClasses.AppCreator;
import com.esri.builder.controllers.supportClasses.AppVersionReader;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.model.ViewerApp;
import com.esri.builder.controllers.supportClasses.XMLFileReader;

import flash.filesystem.File;
import flash.filesystem.FileStream;

public final class ListAppsController
{
    public function ListAppsController()
    {
        AppEvent.addListener(AppEvent.LIST_APP, listAppHandler);
        AppEvent.addListener(AppEvent.APP_CREATED, appCreatedHandler);
        AppEvent.addListener(AppEvent.SETTINGS_SAVED, settingsSavedHandler);
        AppEvent.addListener(AppEvent.UPGRADE_APP_COMPLETE, upgradeAppCompleteHandler);
        AppEvent.addListener(AppEvent.APP_STATE_CHANGED, appStateChangedHandler);
    }

    private function listAppHandler(event:AppEvent):void
    {
        listApps();
    }

    private function appCreatedHandler(event:AppEvent):void
    {
        listApps();
    }

    private function listApps():void
    {
        const appsFound:Array = [];
        const baseDirFiles:Array = Model.instance.baseDir.getDirectoryListing();
        AppEvent.dispatch(AppEvent.APP_FOLDER_LISTED, baseDirFiles.length);
        const xmlFileReader:XMLFileReader = new XMLFileReader(new FileStream());
        const appCreator:AppCreator = new AppCreator(new AppVersionReader(xmlFileReader),
                                                     Model.instance.webServerURL);
        for each (var file:File in baseDirFiles)
        {
            if (file.isDirectory && file.name !== Model.TEMP_DIR_NAME)
            {
                var viewerApp:ViewerApp = appCreator.createViewerFromDirectory(file);
                if (viewerApp)
                {
                    appsFound.push(viewerApp);
                }
            }
            AppEvent.dispatch(AppEvent.APP_FOLDER_ITEM_PROCESSED);
        }

        Model.instance.viewerAppList.source = appsFound;
        Model.instance.status = '';
    }

    private function settingsSavedHandler(event:AppEvent):void
    {
        listApps();
    }

    private function upgradeAppCompleteHandler(event:AppEvent):void
    {
        listApps();
    }

    private function appStateChangedHandler(event:AppEvent):void
    {
        var appState:String = event.data as String;
        if (appState == "home")
        {
            listApps();
        }
    }
}
}
