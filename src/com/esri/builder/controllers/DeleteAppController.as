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
import com.esri.builder.views.popups.DeleteApplicationPopUp;

import flash.display.DisplayObject;

import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

public final class DeleteAppController
{
    private const LOG:ILogger = Log.getLogger('com.esri.builder.controllers.DeleteAppController');

    private var deleteAppPopUp:DeleteApplicationPopUp;
    private var appToDelete:ViewerApp;

    public function DeleteAppController()
    {
        AppEvent.addListener(AppEvent.DELETE_APP, onDeleteApp, false, 0, true);
        AppEvent.addListener(AppEvent.DELETE_EXECUTE, onDeleteExecute, false, 0, true);
    }

    private function onDeleteApp(event:AppEvent):void
    {
        appToDelete = event.data as ViewerApp;
        deleteAppPopUp = new DeleteApplicationPopUp();
        deleteAppPopUp.applicationName = appToDelete.label;
        deleteAppPopUp.addEventListener(CloseEvent.CLOSE, deleteAppPopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(deleteAppPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(deleteAppPopUp);
    }

    private function onDeleteExecute(event:AppEvent):void
    {
        Model.instance.status = '';

        try
        {
            deleteApp(appToDelete);
        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Could not delete directory: {0}', e.message);
            }

            Model.instance.status = e.message.toString();
            BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'deleteApplicationPopUp.couldNotDelete', [ e.message.toString()]),
                              ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
    }

    protected function deleteAppPopUp_closeHandler(event:CloseEvent):void
    {
        PopUpManager.removePopUp(deleteAppPopUp);
        deleteAppPopUp = null;
    }

    private function deleteApp(viewerApp:ViewerApp):void
    {
        if (Log.isInfo())
        {
            LOG.info("Deleting application {0}", viewerApp.label);
        }
        viewerApp.directory.deleteDirectory(true);
        Model.instance.status = ResourceManager.getInstance().getString('BuilderStrings',
                                                                        'deleteAppController.deleted',
                                                                        [ viewerApp.directory.name ]);
        AppEvent.dispatch(AppEvent.LIST_APP);
    }
}
}
