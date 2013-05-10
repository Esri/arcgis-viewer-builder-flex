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
package com.esri.builder.controllers.supportClasses.processes
{

import com.esri.builder.controllers.supportClasses.*;

import flash.filesystem.File;

import mx.resources.ResourceManager;

public class CopyWidgetsProcess extends Process
{
    private var sourceAppDirectory:File;
    protected var destinationAppDirectory:File;

    public function CopyWidgetsProcess(sourceAppDirectory:File, destinationAppDirectory:File)
    {
        this.sourceAppDirectory = sourceAppDirectory;
        this.destinationAppDirectory = destinationAppDirectory;
    }

    override public function execute():void
    {
        try
        {
            var widgetSWFs:Array = findNestedWidgetSWFs(sourceAppDirectory.resolvePath("widgets"), []);
            copyWidgetSWFsToDestinationAppFolder(widgetSWFs);
            dispatchSuccess("Widgets copied!");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'appUpgradeProcess.couldNotCopyWidgets',
                                                                              [ error.message ]);
            dispatchFailure(errorMessage);
        }
    }

    //TODO: remove input widgetSWFs array param
    private function findNestedWidgetSWFs(directory:File, foundWidgetSWFs:Array):Array
    {
        if (!directory.exists)
        {
            return foundWidgetSWFs;
        }

        var widgetFilesOrFolders:Array = directory.getDirectoryListing();

        for each (var fileOrFolder:File in widgetFilesOrFolders)
        {
            if (fileOrFolder.isDirectory)
            {
                findNestedWidgetSWFs(fileOrFolder, foundWidgetSWFs);
            }
            else if (isWidgetFile(fileOrFolder))
            {
                foundWidgetSWFs.push(fileOrFolder);
            }
        }

        return foundWidgetSWFs;
    }

    private function isWidgetFile(fileOrFolder:File):Boolean
    {
        if (fileOrFolder.isDirectory)
        {
            return false;
        }
        else
        {
            var hasSWFExtension:Boolean = (fileOrFolder.extension.toLowerCase() == "swf");
            return hasSWFExtension;
        }
    }

    private function copyWidgetSWFsToDestinationAppFolder(widgetSWFs:Array):void
    {
        for each (var widgetSWF:File in widgetSWFs)
        {
            var widgetRelativeWidgetPath:String = extractWidgetRelativePath(widgetSWF.nativePath);
            var destinationWidgetSWF:File = destinationAppDirectory.resolvePath(widgetRelativeWidgetPath);
            copyWidgetToDestination(widgetSWF, destinationWidgetSWF);
        }
    }

    protected function copyWidgetToDestination(widgetSWF:File, destinationWidgetSWF:File):void
    {
        widgetSWF.copyTo(destinationWidgetSWF, true);
    }

    private function extractWidgetRelativePath(widgetNativePath:String):String
    {
        var pathBeforeWidgetsFolder:RegExp = /(.*[\/|\\])widgets[\/|\\].*/;
        var widgetFolderParentPath:String = widgetNativePath.match(pathBeforeWidgetsFolder)[1]; //1st 
        var widgetRelativeWidgetPath:String = widgetNativePath.replace(widgetFolderParentPath, '');
        return widgetRelativeWidgetPath;
    }
}
}
