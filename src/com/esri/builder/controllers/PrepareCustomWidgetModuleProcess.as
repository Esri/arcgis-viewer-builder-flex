////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2016 Esri. All Rights Reserved.
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

import com.esri.builder.controllers.supportClasses.SharedImportWidgetData;
import com.esri.builder.controllers.supportClasses.processes.ImportWidgetProcess;

import flash.filesystem.File;

public class PrepareCustomWidgetModuleProcess extends ImportWidgetProcess
{
    public function PrepareCustomWidgetModuleProcess(sharedImportWidgetData:SharedImportWidgetData)
    {
        super(sharedImportWidgetData);
    }

    override public function execute():void
    {
        try
        {
            var foundWidgetFiles:Array = [];
            findModuleSWFFile(sharedData.unzipWidgetWorkspace, foundWidgetFiles);

            if (foundWidgetFiles.length > 0)
            {
                sharedData.customWidgetModuleFile = foundWidgetFiles[0];
                dispatchSuccess("Found custom widget module");
            }
            else
            {
                dispatchSuccess("Did not find custom widget module");
            }
        }
        catch (error:Error)
        {
            dispatchSuccess("Did not find custom widget module");
        }
    }

    //TODO: refactor to not require results array
    private function findModuleSWFFile(parentDirectory:File, foundFiles:Array):void
    {
        var widgetModuleFileName:RegExp = /.*Module\.swf/i;
        var files:Array = parentDirectory.getDirectoryListing();
        for each (var file:File in files)
        {
            if (widgetModuleFileName.test(file.name))
            {
                foundFiles.push(file);
                return;
            }
            else if (file.isDirectory)
            {
                findModuleSWFFile(file, foundFiles);
            }
        }
    }
}
}
