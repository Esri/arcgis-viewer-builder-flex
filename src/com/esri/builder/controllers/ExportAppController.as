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
import com.esri.builder.model.ViewerApp;
import com.esri.builder.views.BuilderAlert;
import com.esri.builder.views.popups.ExportApplicationPopUp;

import flash.display.DisplayObject;
import flash.filesystem.File;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;

public class ExportAppController
{
    private const LOG:ILogger = Log.getLogger('com.esri.builder.controllers.ExportController');

    private var selectedProjectFile:File;
    private var exportAppPopUp:ExportApplicationPopUp;

    public function ExportAppController()
    {
        AppEvent.addListener(AppEvent.EXPORT_WINDOW, exportWindowHandler, false, 0, true);
        AppEvent.addListener(AppEvent.EXPORT_EXECUTE, exportExecuteHandler, false, 0, true);
    }

    private function exportWindowHandler(event:AppEvent):void
    {
        selectedProjectFile = (event.data as ViewerApp).directory;

        exportAppPopUp = new ExportApplicationPopUp();
        exportAppPopUp.addEventListener(CloseEvent.CLOSE, createPopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(exportAppPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(exportAppPopUp);
    }

    protected function createPopUp_closeHandler(event:CloseEvent):void
    {
        PopUpManager.removePopUp(exportAppPopUp);
        exportAppPopUp = null;
    }

    private function exportExecuteHandler(event:AppEvent):void
    {
        exportExecute(event.data as File);
    }

    private function exportExecute(outputDirectory:File):void
    {
        if (Log.isInfo())
        {
            LOG.info('exportExecute::outputDirectory={0}', outputDirectory);
        }

        var exportedAppDirectory:File = outputDirectory.resolvePath(selectedProjectFile.name);

        if (exportedAppDirectory.isDirectory === false)
        {
            if (Log.isDebug())
            {
                LOG.debug('Creating application directory {0}', exportedAppDirectory.nativePath);
            }
            var success:Boolean = false;
            try
            {
                exportedAppDirectory.createDirectory();
                success = true;
            }
            catch (e:Error)
            {
                if (Log.isError())
                {
                    LOG.error('Cannot create directory: {0}', e.message);
                }
                BuilderAlert.show(e.message.toString(), ResourceManager.getInstance().getString('BuilderStrings', 'error'));
            }
            if (success)
            {
                exportProject();
            }
        }
        else if (exportedAppDirectory.nativePath === selectedProjectFile.nativePath)
        {
            exportProject();
        }
        else
        {
            const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'exportController.appExistsText', [ exportedAppDirectory.nativePath ]);
            const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'exportController.appExistsTitle');
            BuilderAlert.show(text, title, Alert.YES | Alert.NO, null, closeHandler, null, Alert.NO);
            function closeHandler(event:CloseEvent):void
            {
                if (event.detail === Alert.YES)
                {
                    exportProject();
                }
            }
        }

        function exportProject():void
        {
            if (exportedAppDirectory.nativePath !== selectedProjectFile.nativePath)
            {
                if (Log.isDebug())
                {
                    LOG.debug('Copying {0} to {1}', selectedProjectFile.nativePath, exportedAppDirectory.nativePath);
                }
                try
                {
                    selectedProjectFile.copyTo(exportedAppDirectory, true);
                }
                catch (e:Error)
                {
                    if (Log.isError())
                    {
                        LOG.error('Problem copying directory: {0}', e.message);
                    }
                    Model.instance.status = e.message.toString();
                    BuilderAlert.show(e.message.toString(), ResourceManager.getInstance().getString('BuilderStrings', 'error'));
                    return;
                }
            }

            Model.instance.status = ResourceManager.getInstance().getString('BuilderStrings', 'exportController.status', [ exportedAppDirectory.nativePath ]);
        }

    }
}
}
