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

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;

public class EditAppController
{
    private const LOG:ILogger = Log.getLogger('com.esri.builder.controllers.EditAppController');

    public var loadWidgetConfigurations:LoadWidgetConfigurations;

    public function EditAppController()
    {
        AppEvent.addListener(AppEvent.EDIT_APP, editAppHandler, false, 0, true);
    }

    private function editAppHandler(event:AppEvent):void
    {
        editApp(event.data as ViewerApp);
    }

    private function editApp(viewerApp:ViewerApp):void
    {
        if (Log.isInfo())
        {
            LOG.info('loading viewer application from {0}', viewerApp.directory.nativePath);
        }

        Model.instance.appDir = viewerApp.directory;
        Model.instance.appName = viewerApp.directory.name;

        if (!Model.instance.config.readConfigXML())
        {
            const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'createApp.noConfigXMLText');
            const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'createApp.noConfigXMLTitle');
            Model.instance.status = text;
            BuilderAlert.show(text, title);
        }
        else
        {
            loadWidgetConfigurations.loadWidgetConfigurations();
            Model.instance.config.isDirty = false;
        }

        AppEvent.dispatch(AppEvent.APP_READY_TO_EDIT);
    }
}
}
