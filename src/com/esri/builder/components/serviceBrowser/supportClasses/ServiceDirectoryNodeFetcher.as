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
    private var totalLayerNodesToLoad:int;
    private var layerNodesToLoad:Array;
    private var totalTableNodesToLoad:int;
    private var tableNodesToLoad:Array;

    private var allLayersProcessed:Boolean = true;
    private var allTablesProcessed:Boolean = true;

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

        layerNodesToLoad = [];
        for each (var layer:Object in metadata.layers)
        {
            const layerNode:LayerNode =
                ServiceDirectoryNodeCreator.createLayerNode(parent, layer);
            if (layerNode)
            {
                layerNode.token = token;
                layerNodesToLoad.push(layerNode);
            }
        }

        tableNodesToLoad = [];
        for each (var table:Object in metadata.tables)
        {
            const tableNode:TableNode =
                ServiceDirectoryNodeCreator.createTableNode(parent, table);
            if (tableNode)
            {
                tableNode.token = token;
                tableNodesToLoad.push(tableNode);
            }
        }

        if (layerNodesToLoad.length > 0)
        {
            allLayersProcessed = false;
            fetchLayerNodeInfo();
        }
        if (tableNodesToLoad.length > 0)
        {
            allTablesProcessed = false;
            fetchTableNodeInfo();
        }

        if (layerNodesToLoad.length == 0 && tableNodesToLoad.length == 0)
        {
            dispatchNodeFetchComplete();
        }
    }

    private function fetchLayerNodeInfo():void
    {
        totalLayerNodesToLoad = layerNodesToLoad.length;
        var urlVars:URLVariables;
        var layerInfoRequest:JSONTask;
        for each (var layerNode:LayerNode in layerNodesToLoad)
        {
            urlVars = new URLVariables();
            urlVars.f = "json";
            layerInfoRequest = new JSONTask(layerNode.internalURL);
            layerInfoRequest.requestTimeout = getValidRequestTimeout();
            layerInfoRequest.token = token;
            layerInfoRequest.execute(urlVars,
                                     new AsyncResponder(layerInfoRequest_resultHandler,
                                                        layerNodeInfoRequest_faultHandler,
                                                        layerNode));
        }
    }

    private function fetchTableNodeInfo():void
    {
        totalTableNodesToLoad = tableNodesToLoad.length;
        var urlVars:URLVariables;
        var tableInfoRequest:JSONTask;
        for each (var tableNode:TableNode in tableNodesToLoad)
        {
            urlVars = new URLVariables();
            urlVars.f = "json";
            tableInfoRequest = new JSONTask(tableNode.internalURL);
            tableInfoRequest.requestTimeout = getValidRequestTimeout();
            tableInfoRequest.token = token;
            tableInfoRequest.execute(urlVars,
                                     new AsyncResponder(tableInfoRequest_resultHandler,
                                                        tableNodeInfoRequest_faultHandler,
                                                        tableNode));
        }
    }

    private function layerNodeInfoRequest_faultHandler(fault:Fault, token:Object = null):void
    {
        layerProcessed();
    }

    private function tableNodeInfoRequest_faultHandler(fault:Fault, token:Object = null):void
    {
        tableProcessed();
    }

    private function layerProcessed():void
    {
        totalLayerNodesToLoad--;
        if (totalLayerNodesToLoad == 0)
        {
            addProcessedLayerNodesAndDispatchFetchComplete();
        }
    }

    private function tableProcessed():void
    {
        totalTableNodesToLoad--;
        if (totalTableNodesToLoad == 0)
        {
            addProcessedTableNodesAndDispatchFetchComplete();
        }
    }

    private function addProcessedLayerNodesAndDispatchFetchComplete():void
    {
        for each (var layerNode:LayerNode in layerNodesToLoad)
        {
            if (nodeFilter.isApplicable(layerNode))
            {
                nodes.push(layerNode);
            }
        }
        allLayersProcessed = true;
        if (allLayersProcessed && allTablesProcessed)
        {
            dispatchNodeFetchComplete();
        }
    }

    private function addProcessedTableNodesAndDispatchFetchComplete():void
    {
        for each (var tableNode:TableNode in tableNodesToLoad)
        {
            if (nodeFilter.isApplicable(tableNode))
            {
                nodes.push(tableNode);
            }
        }
        allTablesProcessed = true;
        if (allLayersProcessed && allTablesProcessed)
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

    private function layerInfoRequest_resultHandler(metadata:Object, layerNode:LayerNode):void
    {
        layerNode.metadata = metadata;
        layerProcessed();
    }

    private function tableInfoRequest_resultHandler(metadata:Object, tableNode:TableNode):void
    {
        tableNode.metadata = metadata;
        tableProcessed();
    }

    private function nodeInfoRequest_faultHandler(fault:Fault, token:Object = null):void
    {
        dispatchEvent(new FaultEvent(FaultEvent.FAULT, false, false, fault));
    }
}
}
