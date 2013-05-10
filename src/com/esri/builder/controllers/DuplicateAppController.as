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
import com.esri.builder.views.popups.DuplicateApplicationPopUp;

import flash.display.DisplayObject;
import flash.filesystem.File;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;

public final class DuplicateAppController
{
    private const LOG:ILogger = Log.getLogger('com.esri.builder.controllers.DuplicateAppController');

    private var duplicateAppPopUp:DuplicateApplicationPopUp;
    private var appToDuplicate:ViewerApp;

    public function DuplicateAppController()
    {
        AppEvent.addListener(AppEvent.DUPLICATE_APP, onDuplicateApp, false, 0, true);
    }

    private function onDuplicateApp(event:AppEvent):void
    {
        appToDuplicate = event.data as ViewerApp;
        duplicateAppPopUp = new DuplicateApplicationPopUp();
        duplicateAppPopUp.applicationName = appToDuplicate.label;
        duplicateAppPopUp.addEventListener(CloseEvent.CLOSE, duplicatePopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(duplicateAppPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(duplicateAppPopUp);
        AppEvent.addListener(AppEvent.DUPLICATE_EXECUTE, onDuplicateExecute, false, 0, true);
    }

    protected function duplicatePopUp_closeHandler(event:CloseEvent):void
    {
        closePopUp();
    }

    private function closePopUp():void
    {
        if (duplicateAppPopUp)
        {
            PopUpManager.removePopUp(duplicateAppPopUp);
            duplicateAppPopUp = null;
            AppEvent.removeListener(AppEvent.DUPLICATE_EXECUTE, onDuplicateExecute);
        }
    }

    private function onDuplicateExecute(event:AppEvent):void
    {
        closePopUp();
        duplicateAppIfPossible(event.data as String);
    }

    private function duplicateAppIfPossible(duplicateAppName:String):void
    {
        if (Log.isInfo())
        {
            LOG.info('duplicateExecute::projectName={0}, duplicateName={1}', appToDuplicate.label, duplicateAppName);
        }

        var duplicateAppFile:File = appToDuplicate.directory.parent.resolvePath(duplicateAppName);
        if (duplicateAppFile.isDirectory)
        {
            const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'deployController.appExistsText', [ duplicateAppName ]);
            const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'deployController.appExistsTitle');
            BuilderAlert.show(text, title, Alert.YES | Alert.NO, null, closeHandler, null, Alert.NO);
            function closeHandler(event:CloseEvent):void
            {
                if (event.detail === Alert.YES)
                {
                    duplicateApp(duplicateAppFile)
                }
                else
                {
                    Model.instance.status = '';
                }
            }
        }
        else if (duplicateAppFile.exists)
        {
            BuilderAlert.show(
                ResourceManager.getInstance().getString('BuilderStrings', 'deployController.appExists', [ duplicateAppName ]),
                ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
        else
        {
            duplicateApp(duplicateAppFile);
        }
    }

    private function duplicateApp(duplicateApp:File):void
    {
        try
        {
            appToDuplicate.directory.copyTo(duplicateApp, true);
        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Problem copying directory: {0}', e.message);
            }
            Model.instance.status = e.message.toString();
            BuilderAlert.show(e.message.toString(), ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }

        AppEvent.dispatch(AppEvent.LIST_APP);
    }
}
}
