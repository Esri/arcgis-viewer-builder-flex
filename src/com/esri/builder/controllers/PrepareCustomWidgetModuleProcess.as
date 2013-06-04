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
import com.esri.builder.model.CustomWidgetType;
import com.esri.builder.model.WidgetType;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.supportClasses.FileUtil;

import flash.filesystem.File;

import mx.resources.ResourceManager;

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
            if (willClashWithCoreWidget(sharedData.customWidgetName))
            {
                var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                  'importWidgetProcess.customWidgetNameConflict',
                                                                                  [ sharedData.customWidgetName ]);
                dispatchFailure(errorMessage);
                return;
            }

            var foundWidgetFile:File = findModuleSWFFile(sharedData.unzipWidgetWorkspace);
            if (foundWidgetFile)
            {
                sharedData.customWidgetModuleFile = foundWidgetFile;
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

    private function willClashWithCoreWidget(widgetName:String):Boolean
    {
        var coreWidget:WidgetType = WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.findWidgetTypeByName(widgetName);
        var coreLayoutWidget:WidgetType = WidgetTypeRegistryModel.getInstance().layoutWidgetTypeRegistry.findWidgetTypeByName(widgetName);

        return (coreWidget && !(coreWidget is CustomWidgetType)
            || (coreLayoutWidget && !(coreLayoutWidget is CustomWidgetType)));
    }

    private function findModuleSWFFile(parentDirectory:File):File
    {
        const widgetModuleFileName:RegExp = /.*Module\.swf/i;
        return FileUtil.findMatchingFile(parentDirectory, widgetModuleFileName);
    }
}
}
