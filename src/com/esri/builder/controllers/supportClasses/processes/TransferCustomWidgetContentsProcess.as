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

import com.esri.builder.model.WidgetType;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.views.BuilderAlert;

import flash.filesystem.File;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.resources.ResourceManager;

public class TransferCustomWidgetContentsProcess extends ImportWidgetProcess
{
    public function TransferCustomWidgetContentsProcess(sharedData:SharedImportWidgetData)
    {
        super(sharedData);
    }

    override public function execute():void
    {
        var existingWidgetType:WidgetType = WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.findWidgetTypeByName(sharedData.customWidgetName);
        if (existingWidgetType)
        {
            var overwriteWidgetWarningTitle:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                             'importWidgetProcess.overwriteExistingWidget');
            var overwriteWidgetWarning:String = createOverwriteWidgetWarning(existingWidgetType.version);

            BuilderAlert.show(overwriteWidgetWarning, overwriteWidgetWarningTitle, Alert.YES | Alert.NO, null, overwriteWidgetAlert_closeHandler, null, Alert.NO);
        }
        else
        {
            transferCustomWidgetContents();
        }
    }

    private function createOverwriteWidgetWarning(existingWidgetVersion:String):String
    {
        var overwriteWidgetWarning:String;
        if (existingWidgetVersion && sharedData.customWidgetVersion)
        {
            overwriteWidgetWarning = ResourceManager.getInstance().getString('BuilderStrings',
                                                                             'importWidgetProcess.existingWidgetFoundWithVersions',
                                                                             [ sharedData.customWidgetName, existingWidgetVersion, sharedData.customWidgetVersion ]);
        }
        else
        {
            overwriteWidgetWarning = ResourceManager.getInstance().getString('BuilderStrings',
                                                                             'importWidgetProcess.existingWidgetFound',
                                                                             [ sharedData.customWidgetName ]);
        }
        return overwriteWidgetWarning;
    }

    private function overwriteWidgetAlert_closeHandler(event:CloseEvent):void
    {
        if (event.detail == Alert.YES)
        {
            sharedData.replacedExistingCustomWidget = true;
            transferCustomWidgetContents();
        }
        else
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'importWidgetProcess.processCancelledByUser');
            dispatchFailure(errorMessage);
        }
    }

    private function transferCustomWidgetContents():void
    {
        try
        {
            moveMetaToModulesFolder();
            moveCustomWidgetFolderToWidgetsFolder();
            dispatchSuccess("Custom widget contents transferred");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'importWidgetProcess.couldNotTransferCustomWidgetContents',
                                                                              [ error.message ]);
            dispatchFailure(errorMessage);
        }
    }

    private function moveMetaToModulesFolder():void
    {
        var customModuleConfigDestination:File = getCustomModuleConfigDestination();
        sharedData.customWidgetModuleConfigFile = customModuleConfigDestination;
        sharedData.metaFile.moveTo(customModuleConfigDestination, true);
    }

    private function getCustomModuleConfigDestination():File
    {
        var customModuleConfigName:String = sharedData.customWidgetName + "Module.xml";
        var customModuleConfigDestination:File = sharedData.customModulesDirectory.resolvePath(customModuleConfigName);
        return customModuleConfigDestination;
    }

    private function moveCustomWidgetFolderToWidgetsFolder():void
    {
        var customWidgetDestination:File = getCustomWidgetDestination();
        sharedData.customWidgetFile.parent.moveTo(customWidgetDestination, true);
    }

    private function getCustomWidgetDestination():File
    {
        var customWidgetDestination:File = sharedData.customFlexViewerDirectory.resolvePath("widgets/" + sharedData.customWidgetName);
        return customWidgetDestination;
    }
}
}
