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

import com.esri.builder.supportClasses.URLUtil;
import com.esri.builder.components.serviceBrowser.filters.INodeFilter;
import com.esri.builder.components.serviceBrowser.supportClasses.ServiceDirectoryNodeFetchEvent;
import com.esri.builder.components.serviceBrowser.supportClasses.ServiceDirectoryNodeFetcher;
import com.esri.builder.components.serviceBrowser.supportClasses.URLNodeTraversalEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

public class ServiceDirectoryNode extends EventDispatcher implements ILazyLoadNode
{
    public var metadata:Object;
    public var childrenLoaded:Boolean = false;
    public var isLoadingChildren:Boolean = false;

    private var _children:ArrayCollection = new ArrayCollection();

    public function get children():ArrayCollection
    {
        return _children;
    }

    private var _pathsToFollow:Array;

    public function get pathsToFollow():Array
    {
        return _pathsToFollow;
    }

    public function set pathsToFollow(value:Array):void
    {
        _pathsToFollow = value;
    }

    private var _parent:ServiceDirectoryNode;

    public function get parent():ServiceDirectoryNode
    {
        return _parent;
    }

    private var _name:String;

    public function get name():String
    {
        return _name;
    }

    private var _label:String;

    public function get label():String
    {
        //cache
        return _label ||= URLUtil.decode(_name).replace(/_/g, ' ');
    }

    public function get displayLabel():String
    {
        return label;
    }

    public function get path():String
    {
        return name;
    }

    public function get url():String
    {
        return parent.url + '/' + name;
    }

    public function get isBranch():Boolean
    {
        return true;
    }

    public function get hasChildren():Boolean
    {
        return true;
    }

    private var _nodeFilter:INodeFilter;

    protected function get nodeFilter():INodeFilter
    {
        return _nodeFilter ? _nodeFilter : parent.nodeFilter;
    }

    protected function set nodeFilter(value:INodeFilter):void
    {
        _nodeFilter = value;
    }

    private var _token:String;

    public function get token():String
    {
        return _token;
    }

    public function set token(value:String):void
    {
        _token = value;
    }

    public function ServiceDirectoryNode(parent:ServiceDirectoryNode, name:String)
    {
        _name = URLUtil.encode(name);
        _parent = parent;
        setAsLoading();
    }

    private function setAsLoading():void
    {
        children.addItem(new LoadingNode());
    }

    public function loadChildren():void
    {
        if (childrenLoaded)
        {
            return;
        }

        if (isLoadingChildren)
        {
            return;
        }
        else
        {
            isLoadingChildren = true;
        }

        const nodeFetcher:ServiceDirectoryNodeFetcher = new ServiceDirectoryNodeFetcher();
        nodeFetcher.addEventListener(ServiceDirectoryNodeFetchEvent.NODE_FETCH_COMPLETE, nodeFetcher_nodeFetchCompleteHandler);
        nodeFetcher.addEventListener(FaultEvent.FAULT, nodeFetcher_faultHandler);
        nodeFetcher.token = token;
        nodeFetcher.fetch(url, nodeFilter, this);
    }

    protected function nodeFetcher_nodeFetchCompleteHandler(event:ServiceDirectoryNodeFetchEvent):void
    {
        const nodeFetcher:ServiceDirectoryNodeFetcher = event.currentTarget as ServiceDirectoryNodeFetcher;
        nodeFetcher.removeEventListener(Event.COMPLETE, nodeFetcher_nodeFetchCompleteHandler);
        nodeFetcher.removeEventListener(FaultEvent.FAULT, nodeFetcher_faultHandler);

        childrenLoaded = true;
        isLoadingChildren = false;
        children.source = event.nodes;

        if (children.length == 0)
        {
            setAsEmptyNode();
        }

        postProcessChildrenLoaded();
    }

    protected function postProcessChildrenLoaded():void
    {
        if (!pathsToFollow)
        {
            return;
        }

        if (pathsToFollow.length == 0)
        {
            dispatchPathURLNodeEndReached([]);
            return;
        }

        const nextPath:String = pathsToFollow.shift();
        var canFollowPath:Boolean = false;

        var lazyLoadNode:ILazyLoadNode;
        for each (var child:Object in children)
        {
            lazyLoadNode = child as ILazyLoadNode;
            if (lazyLoadNode)
            {
                if (lazyLoadNode.path.toLowerCase() == nextPath.toLowerCase())
                {
                    lazyLoadNode.pathsToFollow = pathsToFollow;
                    lazyLoadNode.loadChildren();
                    canFollowPath = true;
                    break;
                }
            }
        }

        if (!canFollowPath)
        {
            dispatchPathURLNodeEndReached([]);
        }
    }

    public function dispatchPathURLNodeEndReached(urlNodes:Array):void
    {
        urlNodes.push(this);

        if (parent)
        {
            parent.dispatchPathURLNodeEndReached(urlNodes);
        }
        else
        {
            dispatchEvent(
                new URLNodeTraversalEvent(URLNodeTraversalEvent.END_REACHED, urlNodes));
        }
    }

    private function setAsEmptyNode():void
    {
        children.addItem(new EmptyNode());
    }

    protected function nodeFetcher_faultHandler(event:FaultEvent):void
    {
        const nodeFetcher:ServiceDirectoryNodeFetcher = event.currentTarget as ServiceDirectoryNodeFetcher;
        nodeFetcher.removeEventListener(Event.COMPLETE, nodeFetcher_nodeFetchCompleteHandler);
        nodeFetcher.removeEventListener(FaultEvent.FAULT, nodeFetcher_faultHandler);

        children.removeAll();
        setAsErrorNode();

        processNodeFetchFault(event.fault);
    }

    private function setAsErrorNode():void
    {
        children.addItem(new ErrorNode());
    }

    protected function processNodeFetchFault(fault:Fault):void
    {
        //hook
    }
}
}
