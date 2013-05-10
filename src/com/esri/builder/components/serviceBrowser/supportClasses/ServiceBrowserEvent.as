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
package com.esri.builder.components.serviceBrowser.supportClasses
{

import flash.events.Event;

public class ServiceBrowserEvent extends Event
{
    public static const SELECTION_CHANGE:String = "selectionChange";
    public static const ITEM_SELECTED:String = "itemSelected";

    private var _hasValidSelection:Boolean;

    public function get hasValidSelection():Boolean
    {
        return _hasValidSelection;
    }

    public function ServiceBrowserEvent(type:String, hasValidSelection:Boolean)
    {
        super(type);
        _hasValidSelection = hasValidSelection;
    }

    public override function clone():Event
    {
        return new ServiceBrowserEvent(type, hasValidSelection);
    }
}
}
