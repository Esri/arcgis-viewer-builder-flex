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

import mx.logging.ILogger;
import mx.resources.ResourceManager;

public final class LoadAppController
{
    private static const LOG:ILogger = LogUtil.createLogger(LoadAppController);

    public function LoadAppController()
    {
        AppEvent.addListener(AppEvent.LOAD_APP, loadAppHandler, false, 0, true);
    }

    private function loadAppHandler(event:AppEvent):void
    {
        const viewerApp:ViewerApp = event.data as ViewerApp;

        if (viewerApp.version == Model.SUPPORTED_VIEWER_VERSION)
        {
            LOG.info("Loading app for editing");

            AppEvent.dispatch(AppEvent.EDIT_APP, viewerApp);
        }
        else if (viewerApp.version < Model.SUPPORTED_VIEWER_VERSION)
        {
            LOG.info("Loading app outdated app");

            AppEvent.dispatch(AppEvent.UPGRADE_APP_SELECTED, viewerApp);
        }
        else
        {
            LOG.info("Attempted to load unsupported app");

            showUnsupportedViewerMessage(viewerApp);
        }
    }

    private function showUnsupportedViewerMessage(viewerApp:ViewerApp):void
    {
        BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'unsupportedViewerMessage', [ viewerApp.version ]),
                          ResourceManager.getInstance().getString('BuilderStrings', 'unsupportedViewer'));
    }
}
}
