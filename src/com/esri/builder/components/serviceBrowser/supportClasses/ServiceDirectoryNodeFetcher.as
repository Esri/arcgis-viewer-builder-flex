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

import com.esri.ags.tasks.JSONTask;
import com.esri.builder.components.serviceBrowser.filters.INodeFilter;
import com.esri.builder.components.serviceBrowser.nodes.FolderNode;
import com.esri.builder.components.serviceBrowser.nodes.GPTaskNode;
import com.esri.builder.components.serviceBrowser.nodes.LayerNode;
import com.esri.builder.components.serviceBrowser.nodes.QueryableNode;
import com.esri.builder.components.serviceBrowser.nodes.RouteLayerNode;
import com.esri.builder.components.serviceBrowser.nodes.ServerNode;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryNode;
import com.esri.builder.components.serviceBrowser.nodes.TableNode;

import flash.events.EventDispatcher;
import flash.net.URLVariables;

import mx.rpc.AsyncResponder;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

public class ServiceDirectoryNodeFetcher extends EventDispatcher
{
    private const DEFAULT_TIMEOUT_IN_SECONDS:int = 10;

    public var token:String;
    public var requestTimeout:int;

    private var nodes:Array;
    private var nodeFilter:INodeFilter;
    private var totalNodesToLoad:int;
    private var nodesToLoad:Array;

    private var allNodesProcessed:Boolean = true;

    public function fetch(url:String, nodeFilter:INodeFilter, parent:ServiceDirectoryNode):void
    {
        this.nodeFilter = nodeFilter;

        const urlVars:URLVariables = new URLVariables();
        urlVars.f = "json";

        const nodeInfoRequest:JSONTask = new JSONTask(url);
        nodeInfoRequest.requestTimeout = getValidRequestTimeout();
        nodeInfoRequest.token = token;
        nodeInfoRequest.execute(urlVars,
                                new AsyncResponder(nodeInfoRequest_resultHandler,
                                                   nodeInfoRequest_faultHandler,
                                                   parent));
    }

    private function getValidRequestTimeout():int
    {
        const isRequestTimeoutValid:Boolean = !isNaN(requestTimeout) && requestTimeout > -1;
        return isRequestTimeoutValid ? requestTimeout : DEFAULT_TIMEOUT_IN_SECONDS;
    }

    private function nodeInfoRequest_resultHandler(metadata:Object, parent:ServiceDirectoryNode):void
    {
        nodes = [];

        for each (var folderName:String in metadata.folders)
        {
            const folderNode:FolderNode =
                ServiceDirectoryNodeCreator.createFolderNode(parent, folderName);
            if (nodeFilter.isApplicable(folderNode))
            {
                folderNode.token = token;
                nodes.push(folderNode);
            }
        }

        for each (var taskName:String in metadata.tasks)
        {
            const taskNode:GPTaskNode =
                ServiceDirectoryNodeCreator.createGPTaskNode(parent, taskName);
            if (nodeFilter.isApplicable(taskNode))
            {
                taskNode.token = token;
                nodes.push(taskNode);
            }
        }

        for each (var service:Object in metadata.services)
        {
            const serverNode:ServerNode =
                ServiceDirectoryNodeCreator.createServerNode(parent, service);
            if (nodeFilter.isApplicable(serverNode))
            {
                serverNode.isBranch = nodeFilter.serverChildrenAllowed;
                serverNode.token = token;
                nodes.push(serverNode);
            }
        }

        for each (var routeLayerName:String in metadata.routeLayers)
        {
            const routeNode:RouteLayerNode =
                ServiceDirectoryNodeCreator.createRouteNode(parent, routeLayerName);
            if (nodeFilter.isApplicable(routeNode))
            {
                routeNode.token = token;
                nodes.push(routeNode);
            }
        }

        nodesToLoad = [];
        for each (var layer:Object in metadata.layers)
        {
            const layerNode:LayerNode =
                ServiceDirectoryNodeCreator.createLayerNode(parent, layer);
            if (layerNode)
            {
                layerNode.token = token;
                nodesToLoad.push(layerNode);
            }
        }

        for each (var table:Object in metadata.tables)
        {
            const tableNode:TableNode =
                ServiceDirectoryNodeCreator.createTableNode(parent, table);
            if (tableNode)
            {
                tableNode.token = token;
                nodesToLoad.push(tableNode);
            }
        }

        if (nodesToLoad.length > 0)
        {
            allNodesProcessed = false;
            fetchQueryableNodeInfo();
        }

        if (nodesToLoad.length == 0)
        {
            dispatchNodeFetchComplete();
        }
    }

    private function fetchQueryableNodeInfo():void
    {
        totalNodesToLoad = nodesToLoad.length;
        var urlVars:URLVariables;
        var layerInfoRequest:JSONTask;
        for each (var queryableNode:QueryableNode in nodesToLoad)
        {
            urlVars = new URLVariables();
            urlVars.f = "json";
            layerInfoRequest = new JSONTask(queryableNode.internalURL);
            layerInfoRequest.requestTimeout = getValidRequestTimeout();
            layerInfoRequest.token = token;
            layerInfoRequest.execute(urlVars,
                                     new AsyncResponder(queryableNodeInfoRequest_resultHandler,
                                                        queryableNodeInfoRequest_faultHandler,
                                                        queryableNode));
        }
    }

    private function queryableNodeInfoRequest_faultHandler(fault:Fault, token:Object = null):void
    {
        nodeProcessed();
    }

    private function nodeProcessed():void
    {
        totalNodesToLoad--;
        if (totalNodesToLoad == 0)
        {
            addProcessedNodesAndDispatchFetchComplete();
        }
    }

    private function addProcessedNodesAndDispatchFetchComplete():void
    {
        for each (var queryableNode:QueryableNode in nodesToLoad)
        {
            if (nodeFilter.isApplicable(queryableNode))
            {
                nodes.push(queryableNode);
            }
        }
        allNodesProcessed = true;
        if (allNodesProcessed)
        {
            dispatchNodeFetchComplete();
        }
    }

    private function dispatchNodeFetchComplete():void
    {
        dispatchEvent(
            new ServiceDirectoryNodeFetchEvent(ServiceDirectoryNodeFetchEvent.NODE_FETCH_COMPLETE,
                                               nodes));
    }

    private function queryableNodeInfoRequest_resultHandler(metadata:Object, queryableNode:QueryableNode):void
    {
        queryableNode.metadata = metadata;
        nodeProcessed();
    }

    private function nodeInfoRequest_faultHandler(fault:Fault, token:Object = null):void
    {
        dispatchEvent(new FaultEvent(FaultEvent.FAULT, false, false, fault));
    }
}
}
