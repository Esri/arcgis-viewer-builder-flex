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

public class ServiceDirectoryNodeFetchEvent extends Event
{
    public static const NODE_FETCH_COMPLETE:String = "nodeFetchComplete";

    private var _nodes:Array;

    public function get nodes():Array
    {
        return _nodes;
    }

    public function ServiceDirectoryNodeFetchEvent(type:String, nodes:Array)
    {
        _nodes = nodes;
        super(type);
    }

    override public function clone():Event
    {
        return new ServiceDirectoryNodeFetchEvent(type, nodes);
    }
}
}
