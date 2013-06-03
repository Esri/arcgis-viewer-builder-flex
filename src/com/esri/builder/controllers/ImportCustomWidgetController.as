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

import com.esri.builder.controllers.supportClasses.processes.CleanUpProcess;
import com.esri.builder.controllers.supportClasses.processes.LoadWidgetTypesProcess;
import com.esri.builder.controllers.supportClasses.processes.PrepareCustomWidgetFolderProcess;
import com.esri.builder.controllers.supportClasses.processes.PrepareMetaFileProcess;
import com.esri.builder.controllers.supportClasses.processes.ProcessArbiter;
import com.esri.builder.controllers.supportClasses.processes.ProcessArbiterEvent;
import com.esri.builder.controllers.supportClasses.SharedImportWidgetData;
import com.esri.builder.controllers.supportClasses.processes.TransferCustomWidgetContentsProcess;
import com.esri.builder.controllers.supportClasses.processes.UnzipProcess;
import com.esri.builder.controllers.supportClasses.WellKnownDirectories;
import com.esri.builder.controllers.supportClasses.WidgetTypeLoader;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.controllers.supportClasses.XMLFileReader;
import com.esri.builder.views.popups.ImportWidgetPopUp;

import flash.display.DisplayObjectContainer;
import flash.filesystem.File;
import flash.filesystem.FileStream;

import mx.core.FlexGlobals;

import org.as3commons.zip.Zip;
import com.esri.builder.controllers.supportClasses.processes.UpgradeExistingCustomWidgetsProcess;

public class ImportCustomWidgetController
{
    private static const UNZIP_WIDGET_WORKSPACE:String = "__unzipWidgetWorkspace__";
    private static const BUNDLED_VIEWER_DIRECTORY_NAME:String = "flexviewer";

    private var importWidgetArbiter:ProcessArbiter;
    private var unzipWidgetWorkspace:File;

    public function ImportCustomWidgetController()
    {
        AppEvent.addListener(AppEvent.IMPORT_CUSTOM_WIDGET, importCustomWidgetHandler);
    }

    private function importCustomWidgetHandler(importCustomWidget:AppEvent):void
    {
        var importWidgetPopUp:ImportWidgetPopUp = new ImportWidgetPopUp();
        importWidgetPopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
        importWidget(importCustomWidget.data as File)
    }

    private function importWidget(zippedWidget:File):void
    {
        unzipWidgetWorkspace = File.applicationStorageDirectory.resolvePath(UNZIP_WIDGET_WORKSPACE);

        importWidgetArbiter = new ProcessArbiter();
        importWidgetArbiter.addEventListener(ProcessArbiterEvent.COMPLETE, importArbiter_completeHandler);
        importWidgetArbiter.addEventListener(ProcessArbiterEvent.FAILURE, importArbiter_failureHandler);

        var sharedImportWidgetData:SharedImportWidgetData = new SharedImportWidgetData();
        sharedImportWidgetData.zippedWidgetFile = zippedWidget;
        sharedImportWidgetData.unzipWidgetWorkspace = unzipWidgetWorkspace;
        sharedImportWidgetData.customModulesDirectory = WellKnownDirectories.getInstance().customModules;
        sharedImportWidgetData.customFlexViewerDirectory = WellKnownDirectories.getInstance().customFlexViewer;

        importWidgetArbiter.addProcess(new CleanUpProcess(unzipWidgetWorkspace));
        importWidgetArbiter.addProcess(new UnzipProcess(sharedImportWidgetData, new FileStream(), new Zip()));
        importWidgetArbiter.addProcess(new PrepareCustomWidgetFolderProcess(sharedImportWidgetData));
        importWidgetArbiter.addProcess(new PrepareCustomWidgetModuleProcess(sharedImportWidgetData));
        importWidgetArbiter.addProcess(new PrepareMetaFileProcess(sharedImportWidgetData,
                                                                  new XMLFileReader(new FileStream())));
        importWidgetArbiter.addProcess(new TransferCustomWidgetContentsProcess(sharedImportWidgetData));
        importWidgetArbiter.addProcess(new LoadWidgetTypesProcess(sharedImportWidgetData, new WidgetTypeLoader()));
        importWidgetArbiter.addProcess(new CleanUpProcess(unzipWidgetWorkspace));
        importWidgetArbiter.addProcess(new UpgradeExistingCustomWidgetsProcess(sharedImportWidgetData));

        importWidgetArbiter.executeProcs();
    }

    protected function importArbiter_completeHandler(event:ProcessArbiterEvent):void
    {
        importWidgetArbiter.removeEventListener(ProcessArbiterEvent.COMPLETE, importArbiter_completeHandler);
        importWidgetArbiter.removeEventListener(ProcessArbiterEvent.FAILURE, importArbiter_failureHandler);
        AppEvent.dispatch(AppEvent.IMPORT_WIDGET_SUCCESS);
    }

    protected function importArbiter_failureHandler(event:ProcessArbiterEvent):void
    {
        importWidgetArbiter.removeEventListener(ProcessArbiterEvent.COMPLETE, importArbiter_completeHandler);
        importWidgetArbiter.removeEventListener(ProcessArbiterEvent.FAILURE, importArbiter_failureHandler);

        var cleanUpProcess:CleanUpProcess = new CleanUpProcess(unzipWidgetWorkspace);
        cleanUpProcess.execute();

        AppEvent.dispatch(AppEvent.IMPORT_WIDGET_FAILURE, event.message);
    }
}
}
