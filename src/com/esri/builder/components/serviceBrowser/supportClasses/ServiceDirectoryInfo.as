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

import com.esri.builder.components.serviceBrowser.filters.INodeFilter;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryNode;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryRootNode;

public class ServiceDirectoryInfo
{
    public function ServiceDirectoryInfo(rootNode:ServiceDirectoryRootNode,
                                         pathNodes:Array,
                                         nodeFilter:INodeFilter,
                                         hasCrossDomain:Boolean,
                                         isSecure:Boolean,
                                         securityWarning:String = null)
    {
        _rootNode = rootNode;
        _pathNodes = pathNodes;
        _endNode = pathNodes[0];
        _nodeFilter = nodeFilter;
        _hasCrossDomain = hasCrossDomain;
        _isSecure = isSecure;
        _securityWarning = securityWarning;
    }

    private var _rootNode:ServiceDirectoryRootNode;

    public function get rootNode():ServiceDirectoryRootNode
    {
        return _rootNode;
    }

    private var _pathNodes:Array;

    public function get pathNodes():Array
    {
        return _pathNodes;
    }

    private var _endNode:ServiceDirectoryNode;

    public function get endNode():ServiceDirectoryNode
    {
        return _endNode;
    }

    private var _nodeFilter:INodeFilter;

    public function get nodeFilter():INodeFilter
    {
        return _nodeFilter;
    }

    private var _hasCrossDomain:Boolean;

    public function get hasCrossDomain():Boolean
    {
        return _hasCrossDomain;
    }

    private var _isSecure:Boolean;

    public function get isSecure():Boolean
    {
        return _isSecure;
    }

    private var _securityWarning:String;

    public function get securityWarning():String
    {
        return _securityWarning;
    }

    public function get url():String
    {
        return _endNode.url;
    }

    public function get hasContent():Boolean
    {
        return _rootNode.children.length > 0;
    }
}
}
