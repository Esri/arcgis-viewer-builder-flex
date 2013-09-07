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
package com.esri.builder.model
{

import com.esri.ags.components.IdentityManager;
import com.esri.ags.components.supportClasses.Credential;
import com.esri.ags.components.supportClasses.OAuthInfo;
import com.esri.ags.portal.Portal;
import com.esri.builder.supportClasses.PortalUtil;
import com.esri.builder.supportClasses.URLUtil;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.utils.StringUtil;

public class PortalModel extends EventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Constants
    //
    //--------------------------------------------------------------------------

    public static const DEFAULT_PORTAL_URL:String = "https://www.arcgis.com/";

    private static const BUILDER_APP_ID:String = "flexappbuilder";

    private static var instance:PortalModel;

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    public static function getInstance():PortalModel
    {
        if (!instance)
        {
            instance = new PortalModel(new SingletonEnforcer());
        }

        return instance;
    }

    public function cleanUpPortalURL(url:String):String
    {
        var cleanURL:String = url;
        cleanURL = StringUtil.trim(cleanURL);
        cleanURL = ensureHTTPSOnArcGISDomains(cleanURL);
        cleanURL = cleanURL.replace(/\/sharing\/content\/items\/?$/i, '');
        cleanURL = URLUtil.ensureTrailingForwardSlash(cleanURL);
        cleanURL = URLUtil.encode(cleanURL);
        return cleanURL;
    }

    private function ensureHTTPSOnArcGISDomains(url:String):String
    {
        return isAGO(url) ? mx.utils.URLUtil.replaceProtocol(url, "https") : url;
    }

    public function canSignOut():Boolean
    {
        var credential:Credential = IdentityManager.instance.findCredential(PortalUtil.toPortalSharingURL(portal.url));
        return portal.signedIn && (credential != null);
    }

    public function hasSameOrigin(serverURL:String):Boolean
    {
        if (serverURL == null)
        {
            serverURL = "";
        }

        var serverURLServerNameWithPort:String = mx.utils.URLUtil.getServerNameWithPort(serverURL);
        var portalServerNameWithPort:String = mx.utils.URLUtil.getServerNameWithPort(portalURL);

        return (serverURLServerNameWithPort == portalServerNameWithPort);
    }

    public function registerOAuthPortal(url:String):void
    {
        var oAuthInfo:OAuthInfo = new OAuthInfo(BUILDER_APP_ID);
        oAuthInfo.portalURL = url;
        IdentityManager.instance.registerOAuthInfos([ oAuthInfo ]);
    }

    public function isAGO(url:String):Boolean
    {
        const isAGO:RegExp = /^https?:\/\/.*arcgis\.com/gi;
        return isAGO.test(url);
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function PortalModel(singletonEnforcer:SingletonEnforcer)
    {
        if (!singletonEnforcer)
        {
            throw new Error("Class should not be instantiated - use getInstance()");
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  portal
    //----------------------------------

    [Bindable]
    public var portal:Portal = new Portal();

    //----------------------------------
    //  portalURL
    //----------------------------------

    /**
     * The ArcGIS Portal URL
     */
    private var _portalURL:String;

    [Bindable("userDefinedPortalURLChanged")]
    public function get portalURL():String
    {
        return _portalURL;
    }

    public function set portalURL(value:String):void
    {
        if (_portalURL != value)
        {
            _portalURL = cleanUpPortalURL(value);
            dispatchEvent(new Event("userDefinedPortalURLChanged"));
        }
    }
}
}

class SingletonEnforcer
{
}
