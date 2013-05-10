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

import flash.net.LocalConnection;

import mx.logging.ILogger;
import mx.logging.Log;

public final class LocalConnectionDelegate
{
    private static const LOG:ILogger = Log.getLogger('com.esri.builder.controllers.supportClasses.LocalConnectionDelegate');
    private static const CNAME:String = '_flexViewer';

    private var m_localConnection:LocalConnection;

    private function get localConnection():LocalConnection
    {
        if (m_localConnection === null)
        {
            if (Log.isDebug())
            {
                LOG.debug("Acquiring local connection");
            }

            m_localConnection = new LocalConnection();
        }
        return m_localConnection;
    }

    public function setTitles(title:String, subtitle:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending titles changes: title {0} - subtitle {1}", title, subtitle);
        }

        localConnection.send(CNAME, 'setTitles', title, subtitle);
    }

    public function setLogo(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending logo changes {0}", value);
        }

        localConnection.send(CNAME, 'setLogo', value);
    }

    public function setTextColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending text color changes {0}", value);
        }

        localConnection.send(CNAME, 'setTextColor', value);
    }

    public function setBackgroundColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending background color changes {0}", value);
        }

        localConnection.send(CNAME, 'setBackgroundColor', value);
    }

    public function setRolloverColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending rollover color changes {0}", value);
        }

        localConnection.send(CNAME, 'setRolloverColor', value);
    }

    public function setSelectionColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending selection color changes {0}", value);
        }

        localConnection.send(CNAME, 'setSelectionColor', value);
    }

    public function setTitleColor(value:uint):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending title color changes {0}", value);
        }

        localConnection.send(CNAME, 'setTitleColor', value);
    }

    public function setLocale(localeChain:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending locale changes {0}", localeChain);
        }

        localConnection.send(CNAME, 'setLocale', localeChain);
    }

    public function setFontName(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending font name changes {0}", value);
        }

        localConnection.send(CNAME, 'setFontName', value);
    }

    public function setAppTitleFontName(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending app title font name changes {0}", value);
        }

        localConnection.send(CNAME, 'setAppTitleFontName', value);
    }

    public function setSubTitleFontName(value:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending subtitle font name changes {0}", value);
        }

        localConnection.send(CNAME, 'setSubTitleFontName', value);
    }

    public function setAlpha(value:Number):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending alpha changes {0}", value);
        }

        localConnection.send(CNAME, 'setAlpha', value);
    }

    public function setPredefinedStyles(value:Object):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Sending predefined changes {0}", value);
        }

        localConnection.send(CNAME, 'setPredefinedStyles', value);
    }
}
}
