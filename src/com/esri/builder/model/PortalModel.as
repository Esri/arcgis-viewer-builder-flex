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

import com.esri.ags.portal.Portal;
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
        cleanURL = replacePreviousDefaultPortalURL(cleanURL);
        cleanURL = cleanURL.replace(/\/sharing\/content\/items\/?$/i, '');
        cleanURL = cleanURL.charAt(cleanURL.length - 1) == "/" ? cleanURL : cleanURL + "/";
        cleanURL = URLUtil.encode(cleanURL);
        return cleanURL;
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

    private function replacePreviousDefaultPortalURL(url:String):String
    {
        const previousDefaultPortalURL:String = "http://www.arcgis.com/";
        return url.replace(previousDefaultPortalURL, DEFAULT_PORTAL_URL);
    }
}
}

class SingletonEnforcer
{
}
