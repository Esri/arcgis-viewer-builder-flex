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

import com.esri.ags.events.PortalEvent;
import com.esri.ags.portal.Portal;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalModel;
import com.esri.builder.supportClasses.LogUtil;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.events.FaultEvent;

public class PortalController
{
    private static const LOG:ILogger = LogUtil.createLogger(PortalController);

    private var lastUsedCultureCode:String;

    private var portal:Portal = PortalModel.getInstance().portal;

    public function PortalController()
    {
        AppEvent.addListener(AppEvent.SETTINGS_SAVED, settingsChangeHandler);
        AppEvent.addListener(AppEvent.PORTAL_SIGN_IN, portalSignInHandler);
        AppEvent.addListener(AppEvent.PORTAL_SIGN_OUT, portalSignOutHandler);
    }

    private function portalSignOutHandler(event:AppEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info("Portal sign out requested");
        }

        portal.addEventListener(PortalEvent.LOAD, portal_loadHandler);
        portal.addEventListener(FaultEvent.FAULT, portal_faultHandler);
        portal.signOut();
    }

    private function portalSignInHandler(event:AppEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info("Portal sign in requested");
        }

        portal.addEventListener(PortalEvent.LOAD, portal_loadHandler);
        portal.addEventListener(FaultEvent.FAULT, portal_faultHandler);
        portal.signIn();
    }

    private function settingsChangeHandler(event:AppEvent):void
    {
        loadPortal(PortalModel.getInstance().portalURL, Model.instance.cultureCode);
    }

    private function loadPortal(url:String, cultureCode:String):void
    {
        if (Log.isInfo())
        {
            LOG.info("Loading Portal");
        }

        if (url)
        {
            var hasPortalURLChanged:Boolean = (portal.url != url);
            var hasCultureCodeChanged:Boolean = (lastUsedCultureCode != cultureCode);
            if (hasPortalURLChanged || hasCultureCodeChanged)
            {
                if (Log.isDebug())
                {
                    LOG.debug("Reloading Portal - URL: {0}, culture code: {1}", url, cultureCode);
                }

                if (hasPortalURLChanged)
                {
                    portal.unload();
                }

                lastUsedCultureCode = cultureCode;
                portal.culture = cultureCode;
                portal.url = url;

                portal.addEventListener(PortalEvent.LOAD, portal_loadHandler);
                portal.addEventListener(FaultEvent.FAULT, portal_faultHandler);
                portal.load();
            }
        }
        else
        {
            unloadPortal();
            AppEvent.dispatch(AppEvent.PORTAL_STATUS_UPDATED);
        }
    }

    private function unloadPortal():void
    {
        if (Log.isDebug())
        {
            LOG.debug("Unloading Portal");
        }

        portal.unload();
    }

    private function portal_loadHandler(event:PortalEvent):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Portal load success");
        }

        //do nothing, load successful
        portal.removeEventListener(PortalEvent.LOAD, portal_loadHandler);
        portal.removeEventListener(FaultEvent.FAULT, portal_faultHandler);

        AppEvent.dispatch(AppEvent.PORTAL_STATUS_UPDATED);
    }

    private function portal_faultHandler(event:FaultEvent):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Portal load fault");
        }

        portal.removeEventListener(PortalEvent.LOAD, portal_loadHandler);
        portal.removeEventListener(FaultEvent.FAULT, portal_faultHandler);

        AppEvent.dispatch(AppEvent.PORTAL_STATUS_UPDATED);
    }
}
}
