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
package com.esri.builder.components
{

import com.esri.ags.events.PortalEvent;
import com.esri.ags.portal.Portal;
import com.esri.builder.supportClasses.PortalUtil;

import mx.rpc.events.FaultEvent;
import mx.utils.URLUtil;

[Exclude(kind="property", name="text")]

[SkinState("busy")]
[SkinState("valid")]
[SkinState("invalid")]

public class PortalURLInputChecker extends URLInputCheckerBase
{
    private const DEFAULT_INSTANCE_NAME:String = "arcgis";

    private var portal:Portal;

    //URL adjusting
    private var portalURL:String;
    private var instanceName:String;
    private var isAdjustingURL:Boolean;
    private var hasTriedExistingInstanceEndPoint:Boolean;
    private var hasTriedDefaultInstanceEndPoint:Boolean;
    private var hasTriedPortalEndPoint:Boolean;

    public var processValidPortalFunction:Function;

    override protected function initURLChecker():void
    {
        portal = new Portal();
        portal.requestTimeout = requestTimeout;
    }

    override protected function commitProperties():void
    {
        if (requestTimeoutChanged)
        {
            portal.requestTimeout = requestTimeout;
            requestTimeoutChanged = false;
        }

        super.commitProperties();
    }

    override protected function triggerURLChecker():void
    {
        portal.load();
    }

    override protected function prepareURLChecker(url:String):void
    {
        portal.url = url;
    }

    override protected function addURLCheckerListeners():void
    {
        portal.addEventListener(PortalEvent.LOAD, portal_loadHandler, false, 0, true);
        portal.addEventListener(FaultEvent.FAULT, portal_faultHandler, false, 0, true);
    }

    protected function portal_loadHandler(event:PortalEvent):void
    {
        resetURLAdjusting();
        removeURLCheckerListeners();

        if (responseValidationFunction == null
            || responseValidationFunction(event.currentTarget as Portal))
        {
            if (processValidPortalFunction != null)
            {
                processValidPortalFunction(event.currentTarget as Portal);
            }

            displayValidURL();
        }
        else
        {
            displayInvalidURL();
        }
    }

    private function resetURLAdjusting():void
    {
        isAdjustingURL = false;
        hasTriedExistingInstanceEndPoint = false;
        hasTriedDefaultInstanceEndPoint = false;
        hasTriedPortalEndPoint = false;
    }

    override protected function displayValidURL():void
    {
        const portalInstanceURL:String = portal.url.replace(/\/sharing\/rest.*/, '');
        setTextInternally(portalInstanceURL);
        super.displayValidURL();
    }

    protected function portal_faultHandler(event:FaultEvent):void
    {
        removeURLCheckerListeners();

        if (isAdjustingURL && hasTriedExistingInstanceEndPoint
            && hasTriedDefaultInstanceEndPoint && hasTriedPortalEndPoint)
        {
            resetURLAdjusting();
            displayInvalidURL();
            return;
        }
        else
        {
            if (!isAdjustingURL)
            {
                isAdjustingURL = true;
                getPortalURLParts();
            }

            var adjustedURL:String;
            if (!hasTriedExistingInstanceEndPoint)
            {
                hasTriedExistingInstanceEndPoint = true;
                adjustedURL = portalURL + instanceName;
                if (PortalUtil.toPortalSharingURL(url)
                    != PortalUtil.toPortalSharingURL(adjustedURL))
                {
                    url = adjustedURL;
                    requestURLValidation();
                    return;
                }
            }

            if (!hasTriedDefaultInstanceEndPoint)
            {
                hasTriedDefaultInstanceEndPoint = true;
                adjustedURL = portalURL + DEFAULT_INSTANCE_NAME;
                if (PortalUtil.toPortalSharingURL(url)
                    != PortalUtil.toPortalSharingURL(adjustedURL))
                {
                    url = adjustedURL;
                    requestURLValidation();
                    return;
                }
            }

            if (!hasTriedPortalEndPoint)
            {
                hasTriedPortalEndPoint = true;
                adjustedURL = portalURL;
                if (PortalUtil.toPortalSharingURL(url)
                    != PortalUtil.toPortalSharingURL(adjustedURL))
                {
                    url = adjustedURL;
                    requestURLValidation();
                    return;
                }
            }

            resetURLAdjusting();
            displayInvalidURL();
        }
    }

    override protected function removeURLCheckerListeners():void
    {
        portal.removeEventListener(PortalEvent.LOAD, portal_loadHandler);
        portal.removeEventListener(FaultEvent.FAULT, portal_faultHandler);
    }

    private function getPortalURLParts():void
    {
        var protocol:String = mx.utils.URLUtil.getProtocol(url);
        var host:String = mx.utils.URLUtil.getServerNameWithPort(url);
        portalURL = protocol + "://" + host + "/";

        var paths:String = url.replace(portalURL, '');
        instanceName = paths.split('/', 1)[0];
    }

    [Bindable("change")]
    [Bindable("textChanged")]
    [CollapseWhiteSpace]
    override public function set text(value:String):void
    {
        resetURLAdjusting();
        super.text = value;
    }
}
}
