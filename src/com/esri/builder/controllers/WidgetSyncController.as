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

import com.esri.builder.controllers.supportClasses.WellKnownDirectories;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.model.WidgetType;
import com.esri.builder.supportClasses.LogUtil;

import flash.filesystem.File;

import mx.logging.ILogger;
import mx.logging.Log;

public class WidgetSyncController
{
    private static const LOG:ILogger = LogUtil.createLogger(WidgetSyncController);

    private var addedWidgetType:WidgetType;

    public function WidgetSyncController()
    {
        AppEvent.addListener(AppEvent.WIDGET_ADDED_TO_APP, widgetAddedToAppHandler);
    }

    private function widgetAddedToAppHandler(event:AppEvent):void
    {
        addedWidgetType = event.data as WidgetType;
        copyMissingFilesToApp(getWidgetDirectory());
    }

    private function getWidgetDirectory():File
    {
        var widgetDirectory:File;
        if (addedWidgetType.isCustom)
        {
            widgetDirectory = WellKnownDirectories.getInstance().customFlexViewer.resolvePath("widgets/" + addedWidgetType.name);
        }
        else
        {
            widgetDirectory = WellKnownDirectories.getInstance().bundledFlexViewer.resolvePath("widgets/" + addedWidgetType.name);
        }
        return widgetDirectory;
    }


    private function copyMissingFilesToApp(widgetDirectory:File):void
    {
        if (!widgetDirectory.exists)
        {
            return;
        }

        if (Log.isInfo())
        {
            LOG.info("Copying missing widget files.");
        }

        var directoryContents:Array = widgetDirectory.getDirectoryListing();
        for each (var fileOrFolder:File in directoryContents)
        {
            if (fileOrFolder.isDirectory)
            {
                copyMissingFilesToApp(fileOrFolder);
            }
            else
            {
                copySafelyToApp(fileOrFolder);
            }
        }
    }

    private function copySafelyToApp(fileOrFolder:File):void
    {
        var relativePathToWidgetDirectory:String = getRelativePathToWidgetDirectory(fileOrFolder);
        var fileDestination:File = Model.instance.appDir.resolvePath(relativePathToWidgetDirectory);
        //only copying missing files
        if (!fileDestination.exists)
        {
            if (Log.isDebug())
            {
                LOG.debug("Copying {0} to {1}", fileOrFolder.nativePath, fileDestination.nativePath);
            }

            try
            {
                fileOrFolder.copyTo(fileDestination);
            }
            catch (error:Error)
            {
                if (Log.isWarn())
                {
                    LOG.warn("Could not copy {0} to {1}: {2}", fileOrFolder.nativePath, fileDestination.nativePath, error.toString());
                }
                    //fail silently
            }
        }
    }

    private function getRelativePathToWidgetDirectory(fileOrFolder:File):String
    {
        if (addedWidgetType.isCustom)
        {
            return WellKnownDirectories.getInstance().customFlexViewer.getRelativePath(fileOrFolder);
        }
        else
        {
            return WellKnownDirectories.getInstance().bundledFlexViewer.getRelativePath(fileOrFolder);
        }
    }
}
}
