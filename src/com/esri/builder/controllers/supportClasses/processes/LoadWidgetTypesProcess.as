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


import mx.resources.ResourceManager;

public class LoadWidgetTypesProcess extends ImportWidgetProcess
{
    private var widgetTypeLoader:WidgetTypeLoader;

    public function LoadWidgetTypesProcess(sharedData:SharedImportWidgetData, widgetTypeLoader:WidgetTypeLoader)
    {
        super(sharedData);
        this.widgetTypeLoader = widgetTypeLoader;
    }

    override public function execute():void
    {
        try
        {
            widgetTypeLoader.loadCustomWidgetTypeConfig(sharedData.customWidgetModuleConfigFile);
            dispatchSuccess("Widget types loaded");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'importWidgetProcess.couldNotLoadCustomWidgets',
                                                                              [ error.message ]);
            dispatchFailure(errorMessage);
        }
    }
}
}
