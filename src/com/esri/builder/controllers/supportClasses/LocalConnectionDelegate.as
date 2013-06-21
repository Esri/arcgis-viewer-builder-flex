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
import mx.logging.Log;

public final class LocalConnectionDelegate
{
    private static const LOG:ILogger = LogUtil.createLogger(LocalConnectionDelegate);
    private static const CONNECTION_NAME:String = '_flexViewer';

    private var _localConnection:LocalConnection;

    private function get localConnection():LocalConnection
    {
        if (_localConnection === null)
        {
            if (Log.isDebug())
            {
                LOG.debug("Acquiring local connection");
            }

            _localConnection = new LocalConnection();
            _localConnection.addEventListener(StatusEvent.STATUS, localConnection_statusHandler);
        }
        return _localConnection;
    }

    private function localConnection_statusHandler(event:StatusEvent):void
    {
        if (event.level == "error")
        {
            if (Log.isDebug())
            {
                LOG.debug("Call failed: {0}", event.toString());
            }
        }
    }

    public function setTitles(title:String, subtitle:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending titles changes: title {0} - subtitle {1}", title, subtitle);
        }

        callViewerMethod('setTitles', title, subtitle);
    }

    private function callViewerMethod(methodName:String, ... values):void
    {
        try
        {
            //use Function#apply to avoid passing rest argument as Array
            localConnection.send.apply(null, [ CONNECTION_NAME, methodName ].concat(values));
        }
        catch (error:Error)
        {
            if (Log.isDebug())
            {
                LOG.debug("Call to Viewer method {0} failed: {1}", methodName, error);
            }
        }
    }

    public function setLogo(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending logo changes {0}", value);
        }

        callViewerMethod('setLogo', value);
    }

    public function setTextColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending text color changes {0}", value);
        }

        callViewerMethod('setTextColor', value);
    }

    public function setBackgroundColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending background color changes {0}", value);
        }

        callViewerMethod('setBackgroundColor', value);
    }

    public function setRolloverColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending rollover color changes {0}", value);
        }

        callViewerMethod('setRolloverColor', value);
    }

    public function setSelectionColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending selection color changes {0}", value);
        }

        callViewerMethod('setSelectionColor', value);
    }

    public function setTitleColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending title color changes {0}", value);
        }

        callViewerMethod('setTitleColor', value);
    }

    public function setLocale(localeChain:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending locale changes {0}", localeChain);
        }

        callViewerMethod('setLocale', localeChain);
    }

    public function setFontName(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending font name changes {0}", value);
        }

        callViewerMethod('setFontName', value);
    }

    public function setAppTitleFontName(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending app title font name changes {0}", value);
        }

        callViewerMethod('setAppTitleFontName', value);
    }

    public function setSubTitleFontName(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending subtitle font name changes {0}", value);
        }

        callViewerMethod('setSubTitleFontName', value);
    }

    public function setAlpha(value:Number):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending alpha changes {0}", value);
        }

        callViewerMethod('setAlpha', value);
    }

    public function setPredefinedStyles(value:Object):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending predefined changes {0}", value);
        }

        callViewerMethod('setPredefinedStyles', value);
    }
}
}
