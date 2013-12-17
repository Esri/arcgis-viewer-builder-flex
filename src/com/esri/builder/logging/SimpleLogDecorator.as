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
package com.esri.builder.logging
{

import flash.events.Event;

import mx.logging.ILogger;
import mx.logging.Log;

public class SimpleLogDecorator implements ILogger
{
    private var logger:ILogger;

    public function SimpleLogDecorator(logger:ILogger)
    {
        this.logger = logger;
    }

    public function get category():String
    {
        return logger.category;
    }

    public function log(level:int, message:String, ... rest):void
    {
        logger.log.apply(null, [ level, message ].concat(rest));
    }

    public function debug(message:String, ... rest):void
    {
        if (Log.isDebug())
        {
            logger.debug.apply(null, [ message ].concat(rest));
        }
    }

    public function error(message:String, ... rest):void
    {
        if (Log.isError())
        {
            logger.error.apply(null, [ message ].concat(rest));
        }
    }

    public function fatal(message:String, ... rest):void
    {
        if (Log.isFatal())
        {
            logger.fatal.apply(null, [ message ].concat(rest));
        }
    }

    public function info(message:String, ... rest):void
    {
        if (Log.isInfo())
        {
            logger.info.apply(null, [ message ].concat(rest));
        }
    }

    public function warn(message:String, ... rest):void
    {
        if (Log.isWarn())
        {
            logger.warn.apply(null, [ message ].concat(rest));
        }
    }

    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        logger.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        logger.removeEventListener(type, listener, useCapture);
    }

    public function dispatchEvent(event:Event):Boolean
    {
        return logger.dispatchEvent(event);
    }

    public function hasEventListener(type:String):Boolean
    {
        return logger.hasEventListener(type);
    }

    public function willTrigger(type:String):Boolean
    {
        return logger.willTrigger(type);
    }
}
}
