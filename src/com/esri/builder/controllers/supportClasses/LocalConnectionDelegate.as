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
package com.esri.builder.controllers.supportClasses
{

import com.esri.builder.supportClasses.LogUtil;

import flash.events.StatusEvent;
import flash.net.LocalConnection;

import mx.logging.ILogger;

public final class LocalConnectionDelegate
{
    private static const LOG:ILogger = LogUtil.createLogger(LocalConnectionDelegate);
    private static const CONNECTION_NAME:String = '_flexViewer';

    private var _localConnection:LocalConnection;

    private function get localConnection():LocalConnection
    {
        if (_localConnection === null)
        {
            LOG.debug("Acquiring local connection");

            _localConnection = new LocalConnection();
            _localConnection.addEventListener(StatusEvent.STATUS, localConnection_statusHandler);
        }
        return _localConnection;
    }

    private function localConnection_statusHandler(event:StatusEvent):void
    {
        if (event.level == "error")
        {
            LOG.debug("Call failed: {0}", event.toString());
        }
    }

    public function setTitles(title:String, subtitle:String):void
    {
        callViewerMethod('setTitles', title, subtitle);
    }

    private function callViewerMethod(methodName:String, ... values):void
    {
        LOG.debug("Calling Viewer method: {0} with the following arguments: {1}", methodName, values);

        try
        {
            //use Function#apply to avoid passing rest argument as Array
            localConnection.send.apply(null, [ CONNECTION_NAME, methodName ].concat(values));
        }
        catch (error:Error)
        {
            LOG.debug("Call to method {0} failed: {1}", methodName, error);
        }
    }

    public function setLogo(value:String):void
    {
        callViewerMethod('setLogo', value);
    }

    public function setTextColor(value:uint):void
    {
        callViewerMethod('setTextColor', value);
    }

    public function setBackgroundColor(value:uint):void
    {
        callViewerMethod('setBackgroundColor', value);
    }

    public function setRolloverColor(value:uint):void
    {
        callViewerMethod('setRolloverColor', value);
    }

    public function setSelectionColor(value:uint):void
    {
        callViewerMethod('setSelectionColor', value);
    }

    public function setTitleColor(value:uint):void
    {
        callViewerMethod('setTitleColor', value);
    }

    public function setLocale(localeChain:String):void
    {
        callViewerMethod('setLocale', localeChain);
    }

    public function setFontName(value:String):void
    {
        callViewerMethod('setFontName', value);
    }

    public function setAppTitleFontName(value:String):void
    {
        callViewerMethod('setAppTitleFontName', value);
    }

    public function setSubTitleFontName(value:String):void
    {
        callViewerMethod('setSubTitleFontName', value);
    }

    public function setAlpha(value:Number):void
    {
        callViewerMethod('setAlpha', value);
    }

    public function setPredefinedStyles(value:Object):void
    {
        callViewerMethod('setPredefinedStyles', value);
    }
}
}
