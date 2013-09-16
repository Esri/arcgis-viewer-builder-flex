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
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.LogUtil;

import flash.filesystem.File;

import mx.logging.ILogger;

public class AppTouchController
{
    private static const LOG:ILogger = LogUtil.createLogger(AppTouchController);

    public function AppTouchController()
    {
        AppEvent.addListener(AppEvent.CONFIG_XML_SAVED, configXMLSavedHandler, false, 0, true);
        AppEvent.addListener(AppEvent.WIDGET_CONFIG_XML_SAVED, widgetConfigXMLSavedHandler, false, 0, true);
    }

    private function configXMLSavedHandler(event:AppEvent):void
    {
        touchAppDirectory();
    }

    private function widgetConfigXMLSavedHandler(event:AppEvent):void
    {
        touchAppDirectory();
    }

    private function touchAppDirectory():void
    {
        var currentAppDir:File = Model.instance.appDir;
        var touchFolder:File = currentAppDir.resolvePath("touch");
        try
        {
            touchFolder.createDirectory();
            touchFolder.deleteDirectory(true);
        }
        catch (e:Error)
        {
            LOG.error("Error touching {0} directory.", currentAppDir.nativePath);
        }
    }
}
}
