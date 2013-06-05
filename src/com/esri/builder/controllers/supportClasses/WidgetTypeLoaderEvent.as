////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2016 Esri. All Rights Reserved.
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

import com.esri.builder.model.WidgetType;

import flash.events.Event;

public class WidgetTypeLoaderEvent extends Event
{
    public static const LOAD_COMPLETE:String = "loadComplete";
    public static const LOAD_ERROR:String = "loadError";

    public function WidgetTypeLoaderEvent(type:String, widgetType:WidgetType = null)
    {
        super(type);
        _widgetType = widgetType;
    }

    private var _widgetType:WidgetType;

    public function get widgetType():WidgetType
    {
        return _widgetType;
    }

    override public function clone():Event
    {
        return new WidgetTypeLoaderEvent(type, _widgetType);
    }
}
}
