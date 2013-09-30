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
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;
import com.esri.builder.views.popups.RenameApplicationPopUp;

import flash.display.DisplayObject;
import flash.errors.IOError;
import flash.filesystem.File;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;

public final class RenameAppController
{
    private const LOG:ILogger = LogUtil.createLogger(RenameAppController);
    private const RENAME_APP_ERROR_MESSAGE:String = 'Problem renaming directory: {0}';

    private var renameAppPopUp:RenameApplicationPopUp;
    private var appToRename:ViewerApp;

    public function RenameAppController()
    {
        AppEvent.addListener(AppEvent.RENAME_APP, onRenameApp, false, 0, true);
    }

    private function onRenameApp(event:AppEvent):void
    {
        appToRename = event.data as ViewerApp;
        renameAppPopUp = new RenameApplicationPopUp();
        renameAppPopUp.applicationName = appToRename.label;
        renameAppPopUp.addEventListener(CloseEvent.CLOSE, renamePopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(renameAppPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(renameAppPopUp);
        AppEvent.addListener(AppEvent.RENAME_EXECUTE, onRenameExecute, false, 0, true);
    }

    protected function renamePopUp_closeHandler(event:CloseEvent):void
    {
        closePopUp();
    }

    private function closePopUp():void
    {
        if (renameAppPopUp)
        {
            PopUpManager.removePopUp(renameAppPopUp);
            renameAppPopUp = null;
            AppEvent.removeListener(AppEvent.RENAME_EXECUTE, onRenameExecute);
        }
    }

    private function onRenameExecute(event:AppEvent):void
    {
        closePopUp();
        renameApp(appToRename, event.data as String);
    }

    private function renameApp(viewerApp:ViewerApp, newName:String):void
    {
        LOG.info('Renaming application {0} to {1}', viewerApp.label, newName);
        const newFile:File = Model.instance.baseDir.resolvePath(newName);
        if (newFile.isDirectory)
        {
            const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'deployController.appExistsText', [ newName ]);
            const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'deployController.appExistsTitle');
            BuilderAlert.show(text, title, Alert.YES | Alert.NO, null, closeHandler, null, Alert.NO);
            function closeHandler(event:CloseEvent):void
            {
                if (event.detail === Alert.YES)
                {
                    doRenameApp(true);
                }
                else
                {
                    Model.instance.status = '';
                }
            }
        }
        else if (newFile.exists)
        {
            BuilderAlert.show(
                ResourceManager.getInstance().getString('BuilderStrings', 'deployController.appExists', [ newName ]),
                ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
        else
        {
            doRenameApp(false);
        }
        function doRenameApp(listApps:Boolean):void
        {
            try
            {
                viewerApp.directory.moveTo(newFile, true);
                viewerApp.directory = newFile;
                if (listApps)
                {
                    AppEvent.dispatch(AppEvent.LIST_APP);
                }
            }
            catch (ioErr:IOError)
            {
                logError(RENAME_APP_ERROR_MESSAGE, ioErr);
                BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'renameApplicationPopUp.cannotRenameMakeSureFileIsNotOpen'),
                                  ResourceManager.getInstance().getString('BuilderStrings', 'error'));
            }
            catch (securityErr:SecurityError)
            {
                logError(RENAME_APP_ERROR_MESSAGE, securityErr);
                BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'renameApplicationPopUp.cannotRenameMakeSureRightPermissions'),
                                  ResourceManager.getInstance().getString('BuilderStrings', 'error'));
            }
            catch (err:Error)
            {
                logError(RENAME_APP_ERROR_MESSAGE, err);
                BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'renameApplicationPopUp.cannotRename'),
                                  ResourceManager.getInstance().getString('BuilderStrings', 'error'));
            }
        }

        function logError(errorMessage:String, error:IOError):void
        {
            LOG.error(errorMessage, error.toString());
        }
    }
}
}
