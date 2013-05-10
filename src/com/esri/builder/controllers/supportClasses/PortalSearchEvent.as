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

import flash.events.Event;

public class PortalSearchEvent extends Event
{
    public static const COMPLETE:String = "portalSearchComplete";

    private var _results:Array;

    public function get results():Array
    {
        return _results;
    }

    public function PortalSearchEvent(type:String, results:Array)
    {
        _results = results;
        super(type);
    }

    override public function clone():Event
    {
        return new PortalSearchEvent(type, results);
    }
}
}
