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
package com.esri.builder.components.serviceBrowser.nodes
{

import com.esri.builder.components.serviceBrowser.filters.INodeFilter;

import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

public class ServiceDirectoryRootNode extends FolderNode
{
    public function ServiceDirectoryRootNode(servicesDirectoryRootURL:String, nodeFilter:INodeFilter)
    {
        this.nodeFilter = nodeFilter;

        const endsWithRestServices:RegExp = /(.+\/rest\/services)\/?(.*)/;
        const servicesRootAndTrailingPaths:Array = endsWithRestServices.exec(servicesDirectoryRootURL);

        var servicesDirectoryRootURL:String;
        if (servicesRootAndTrailingPaths)
        {
            //ignore index 0 as it contains full url
            pathsToFollow = extractPaths(servicesRootAndTrailingPaths[2]);
            servicesDirectoryRootURL = servicesRootAndTrailingPaths[1];
        }

        super(null, servicesDirectoryRootURL);
    }

    private function extractPaths(trailingPaths:String):Array
    {
        const forwardSlashesNotPrecedingWellKnownServerTypes:RegExp =
            /\/ (?! (?: Map | Feature | Image | GP | Geocode | Geometry | NA | Geodata | Globe | Mobile ) Server ) /igx;
        return trailingPaths
            .replace(forwardSlashesNotPrecedingWellKnownServerTypes, "?")
            .split("?");
    }

    override public function get url():String
    {
        return name;
    }

    override public function get isBranch():Boolean
    {
        return true;
    }

    override public function get hasChildren():Boolean
    {
        return true;
    }

    override protected function processNodeFetchFault(fault:Fault):void
    {
        dispatchEvent(FaultEvent.createEvent(fault));
    }
}
}
