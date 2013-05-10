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

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.resources.ResourceManager;

public class LocalizableBreadcrumb extends Breadcrumb implements IEventDispatcher
{
    private var eventDispatcher:IEventDispatcher;

    [Bindable(event="resourceManagerChanged")]
    override public function get label():String
    {
        return ResourceManager.getInstance().getString('BuilderStrings', super.label);
    }

    public function LocalizableBreadcrumb(label:String, stateName:String = null)
    {
        super(label, stateName);
        ResourceManager.getInstance().addEventListener(Event.CHANGE, resourceManager_changeHandler, false, 0, true);
        eventDispatcher = new EventDispatcher(this);
    }

    private function resourceManager_changeHandler(event:Event):void
    {
        eventDispatcher.dispatchEvent(new Event("resourceManagerChanged"));
    }

    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        eventDispatcher.removeEventListener(type, listener, useCapture);
    }

    public function dispatchEvent(event:Event):Boolean
    {
        return eventDispatcher.dispatchEvent(event);
    }

    public function hasEventListener(type:String):Boolean
    {
        return eventDispatcher.hasEventListener(type);
    }

    public function willTrigger(type:String):Boolean
    {
        return eventDispatcher.willTrigger(type);
    }
}
}
