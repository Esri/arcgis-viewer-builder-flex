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

import com.esri.builder.model.Model;
import com.esri.builder.model.ViewerApp;
import com.esri.builder.views.BuilderAlert;

import flash.filesystem.File;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

public class UpgradeExistingCustomWidgetsProcess extends ImportWidgetProcess
{
    public function UpgradeExistingCustomWidgetsProcess(sharedData:SharedImportWidgetData)
    {
        super(sharedData);
    }

    override public function execute():void
    {
        if (sharedData.replacedExistingCustomWidget && isCustomWidgetBeingUsedInExistingApps())
        {
            var upgradeExistingCustomWidgetWarning:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                                    'importWidgetProcess.confirmUpdateCustomWidgetsUsedInApps',
                                                                                                    [ sharedData.customWidgetName ]);
            var upgradeExistingCustomWidgetWarningTitle:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                                         'importWidgetPopUp.title');
            BuilderAlert.show(upgradeExistingCustomWidgetWarning,
                              upgradeExistingCustomWidgetWarningTitle,
                              Alert.YES | Alert.NO,
                              null,
                              overwriteWidgetAlert_closeHandler,
                              null,
                              Alert.NO);
        }
        else
        {
            dispatchSuccess("No need to upgrade existing custom widgets");
        }
    }

    private function isCustomWidgetBeingUsedInExistingApps():Boolean
    {
        var isCustomWidgetBeingUsed:Boolean = false;

        var existingApps:Array = Model.instance.viewerAppList.toArray();
        var viewerRelativePathToWidgetSWF:String = getRelativePathFromViewerToCustomWidgetSWF();
        var existingCustomWidgetSWF:File;
        for each (var app:ViewerApp in existingApps)
        {
            existingCustomWidgetSWF = app.directory.resolvePath(viewerRelativePathToWidgetSWF);
            if (existingCustomWidgetSWF.exists)
            {
                isCustomWidgetBeingUsed = true;
                break;
            }
        }

        return isCustomWidgetBeingUsed;
    }

    private function getRelativePathFromViewerToCustomWidgetSWF():String
    {
        return StringUtil.substitute("widgets/{0}/{0}Widget.swf", sharedData.customWidgetName);
    }

    private function overwriteWidgetAlert_closeHandler(event:CloseEvent):void
    {
        if (event.detail == Alert.YES)
        {
            upgradeCustomWidgetInExistingApps();
        }

        dispatchSuccess("Upgraded existing custom widgets");
    }

    private function upgradeCustomWidgetInExistingApps():void
    {
        var existingApps:Array = Model.instance.viewerAppList.toArray();
        for each (var app:ViewerApp in existingApps)
        {
            upgradeUsedCustomWidget(app);
        }
    }

    private function upgradeUsedCustomWidget(app:ViewerApp):void
    {
        var existingCustomWidgetSWF:File = app.directory.resolvePath(getRelativePathFromViewerToCustomWidgetSWF());
        if (existingCustomWidgetSWF.exists)
        {
            upgradeExistingCustomWidget(existingCustomWidgetSWF);
        }
    }

    private function upgradeExistingCustomWidget(existingCustomWidgetSWF:File):void
    {
        var importedWidgetSWF:File = sharedData.customFlexViewerDirectory.resolvePath(getRelativePathFromViewerToCustomWidgetSWF());
        try
        {
            importedWidgetSWF.copyTo(existingCustomWidgetSWF, true);
        }
        catch (error:Error)
        {
            //fail silently?
        }
    }
}
}
