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
import com.esri.builder.supportClasses.FileUtil;

import flash.filesystem.File;

import mx.resources.ResourceManager;

public class PrepareCustomWidgetFolderProcess extends ImportWidgetProcess
{
    public function PrepareCustomWidgetFolderProcess(sharedData:SharedImportWidgetData)
    {
        super(sharedData);
    }

    override public function execute():void
    {
        try
        {
            var foundWidget:File = findWidgetSWFFile(sharedData.unzipWidgetWorkspace);
            if (!foundWidget)
            {
                dispatchErrorMessage();
                return;
            }

            var widgetName:String = foundWidget.name.replace(/Widget.swf$/i, '');

            sharedData.customWidgetName = widgetName;
            sharedData.customWidgetFile = foundWidget;

            dispatchSuccess("Processed custom widget folder contents");
        }
        catch (error:Error)
        {
            dispatchErrorMessage();
        }
    }

    private function findWidgetSWFFile(parentDirectory:File):File
    {
        const widgetSWFFileName:RegExp = /.*widget\.swf/i;
        return FileUtil.findMatchingFile(parentDirectory, widgetSWFFileName);
    }

    private function dispatchErrorMessage():void
    {
        var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                          'importWidgetProcess.couldNotFindWidgetSWF');
        dispatchFailure(errorMessage);
    }
}
}
