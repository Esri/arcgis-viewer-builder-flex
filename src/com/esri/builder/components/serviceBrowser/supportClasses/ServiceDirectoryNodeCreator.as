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

import com.esri.builder.components.serviceBrowser.nodes.FeatureServerNode;
import com.esri.builder.components.serviceBrowser.nodes.FolderNode;
import com.esri.builder.components.serviceBrowser.nodes.GPServerNode;
import com.esri.builder.components.serviceBrowser.nodes.GPTaskNode;
import com.esri.builder.components.serviceBrowser.nodes.GeocodeServerNode;
import com.esri.builder.components.serviceBrowser.nodes.ImageServerNode;
import com.esri.builder.components.serviceBrowser.nodes.LayerNode;
import com.esri.builder.components.serviceBrowser.nodes.MapServerNode;
import com.esri.builder.components.serviceBrowser.nodes.NAServerNode;
import com.esri.builder.components.serviceBrowser.nodes.ServerNode;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryNode;
import com.esri.builder.components.serviceBrowser.nodes.RouteLayerNode;

public class ServiceDirectoryNodeCreator
{
    private static const FEATURE_SERVER_TYPE:String = 'FeatureServer';
    private static const MAP_SERVER_TYPE:String = 'MapServer';
    private static const IMAGE_SERVER_TYPE:String = 'ImageServer';
    private static const GP_SERVER_TYPE:String = "GPServer";
    private static const GEOCODE_SERVER_TYPE:String = 'GeocodeServer';
    private static const NA_SERVER_TYPE:String = 'NAServer';

    public static function createFolderNode(parent:ServiceDirectoryNode, folderName:String):FolderNode
    {
        return new FolderNode(parent, folderName);
    }

    public static function createServerNode(parent:ServiceDirectoryNode, serviceMetadata:Object):ServerNode
    {
        var serverNode:ServerNode;

        const type:String = serviceMetadata.type;
        const name:String = serviceMetadata.name;

        if (type == IMAGE_SERVER_TYPE)
        {
            serverNode = new ImageServerNode(parent, name, type);
        }
        else if (type == MAP_SERVER_TYPE)
        {
            serverNode = new MapServerNode(parent, name, type);
        }
        else if (type == FEATURE_SERVER_TYPE)
        {
            serverNode = new FeatureServerNode(parent, name, type);
        }
        else if (type == GEOCODE_SERVER_TYPE)
        {
            serverNode = new GeocodeServerNode(parent, name, type);
        }
        else if (type == GP_SERVER_TYPE)
        {
            serverNode = new GPServerNode(parent, name, type);
        }
        else if (type == NA_SERVER_TYPE)
        {
            serverNode = new NAServerNode(parent, name, type);
        }

        return serverNode;
    }

    public static function createGPTaskNode(parent:ServiceDirectoryNode, taskName:String):GPTaskNode
    {
        return new GPTaskNode(parent, taskName);
    }

    public static function createLayerNode(parent:ServiceDirectoryNode, layerMetadata:Object):LayerNode
    {
        var layerNode:LayerNode;

        const isGroupLayer:Boolean = layerMetadata.subLayerIds != null;
        if (!isGroupLayer)
        {
            layerNode = new LayerNode(parent, layerMetadata.name, layerMetadata.id);
        }

        return layerNode;
    }

    public static function createRouteNode(parent:ServiceDirectoryNode, routeName:String):RouteLayerNode
    {
        return new RouteLayerNode(parent, routeName);
    }
}
}
