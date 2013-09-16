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
import com.esri.builder.model.RecentlyUsedURLsModel;
import com.esri.builder.supportClasses.LogUtil;

import flash.events.Event;
import flash.net.SharedObject;

import mx.core.FlexGlobals;
import mx.logging.ILogger;

public class RecentlyUsedURLsController
{
    private static const LOG:ILogger = LogUtil.createLogger(RecentlyUsedURLsController);

    public function RecentlyUsedURLsController()
    {
        AppEvent.addListener(AppEvent.REGISTER_URL, registerURLHandler, false, 0, true);
        AppEvent.addListener(AppEvent.APPLICATION_COMPLETE, applicationCompleteHandler, false, 0, true);
        FlexGlobals.topLevelApplication.addEventListener(Event.CLOSE, applicationCloseHandler, false, 0, true);
    }

    private function registerURLHandler(event:AppEvent):void
    {
        var url:String = event.data as String;
        LOG.debug("Registering URL: {0}", url);
        RecentlyUsedURLsModel.getInstance().addURL(url);
    }

    private function applicationCompleteHandler(event:AppEvent):void
    {
        loadURLs();
    }

    private function loadURLs():void
    {
        LOG.info("Loading URL history");

        var so:SharedObject = SharedObject.getLocal(RecentlyUsedURLsModel.SHARED_OBJECT_NAME);
        if (so.data.urls)
        {
            RecentlyUsedURLsModel.getInstance().loadURLs(so.data.urls);
        }
        so.close();
    }

    private function applicationCloseHandler(event:Event):void
    {
        saveURLs();
    }

    private function saveURLs():void
    {
        LOG.info("Saving URL history");

        var so:SharedObject = SharedObject.getLocal(RecentlyUsedURLsModel.SHARED_OBJECT_NAME);
        so.data.urls = RecentlyUsedURLsModel.getInstance().urls;
        so.close();
    }
}
}
