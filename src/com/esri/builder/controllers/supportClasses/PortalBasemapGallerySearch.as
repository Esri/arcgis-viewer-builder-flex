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

import com.esri.ags.portal.Portal;
import com.esri.ags.portal.supportClasses.PortalGroup;
import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.portal.supportClasses.PortalQueryParameters;
import com.esri.ags.portal.supportClasses.PortalQueryResult;
import com.esri.ags.tasks.JSONTask;
import com.esri.builder.model.ConfigLayer;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalLayer;
import com.esri.builder.supportClasses.LogUtil;

import flash.net.URLVariables;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;

public class PortalBasemapGallerySearch extends PortalSearch
{
    private static const LOG:ILogger = LogUtil.createLogger(PortalBasemapGallerySearch);

    private var basemaps:Array;
    private var totalItemsToProcess:int;
    private var resultItems:Array;

    public function PortalBasemapGallerySearch(portal:Portal)
    {
        super(portal);
    }

    override public function execute(queryParams:PortalQueryParameters):void
    {
        if (Log.isInfo())
        {
            LOG.info("Searching Portal basemap gallery: {0}", queryParams.toString());
        }

        portal.queryGroups(queryParams,
                           new AsyncResponder(groups_resultHandler,
                                              portalQuery_faultHandler));
    }

    protected function groups_resultHandler(queryResult:PortalQueryResult, token:Object = null):void
    {
        if (Log.isInfo())
        {
            LOG.info("Query groups success");
        }

        if (queryResult.results.length > 0)
        {
            getGroup(PortalGroup(queryResult.results[0]).id);
        }
        else
        {
            dispatchCompleteEvent([]);
        }
    }

    private function getGroup(groupId:String):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Fetching Portal basemap group items");
        }

        const queryParams:PortalQueryParameters =
            PortalQueryParameters.forItemsInGroup(groupId).withLimit(50).withSortField("name");

        portal.queryItems(queryParams,
                          new AsyncResponder(search_resultHandler,
                                             portalQuery_faultHandler));
    }

    private function search_resultHandler(queryResult:PortalQueryResult, token:Object):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Basemap group items fetch success");
        }

        basemaps = [];
        resultItems = queryResult.results;
        totalItemsToProcess = resultItems.length;
        for each (var portalItem:PortalItem in resultItems)
        {
            getBasemap(portalItem);
        }
    }

    private function getBasemap(item:PortalItem):void
    {
        const basemap:PortalLayer = new PortalLayer(item);
        if (item.type == PortalItem.TYPE_WEB_MAP)
        {
            if (Log.isDebug())
            {
                LOG.debug("Fetching basemap {0} item", item.type);
            }

            item.getJSONData(
                new AsyncResponder(data_resultHandler, data_faultHandler, basemap));
        }
        else if (item.type == PortalItem.TYPE_MAP_SERVICE)
        {
            if (Log.isDebug())
            {
                LOG.debug("Fetching basemap {0} item", item.type);
            }

            processMapServicePortalItem(item, basemap);
        }
        else
        {
            if (Log.isDebug())
            {
                LOG.debug("Unsupported basemap item type: {0}", item.type);
            }

            decrementTotalItemsToProcess();
        }
    }

    private function processMapServicePortalItem(item:PortalItem, basemap:PortalLayer):void
    {
        var mapServiceMetadataRequest:JSONTask = new JSONTask(item.url);
        var urlVars:URLVariables = new URLVariables();
        urlVars.f = "json";
        mapServiceMetadataRequest.execute(
            urlVars, new AsyncResponder(mapServiceMetadataRequest_resultHandler,
                                        mapServiceMetadataRequest_faultHandler,
                                        { item: item, basemap: basemap }))
    }

    private function mapServiceMetadataRequest_resultHandler(serviceMetadata:Object, itemAndBasemap:Object):void
    {
        var item:PortalItem = itemAndBasemap.item;
        var layerType:String = getLayerType(serviceMetadata, item);
        if (layerType)
        {
            if (Log.isDebug())
            {
                LOG.debug("Adding basemap layer type: {0}", layerType);
            }

            var basemap:PortalLayer = itemAndBasemap.basemap;
            basemap.serviceURL = item.url;
            basemap.type = layerType;
            basemaps.push(basemap);
        }
        else
        {
            if (Log.isDebug())
            {
                LOG.debug("Unsupported basemap layer type: {0}", layerType);
            }
        }

        decrementTotalItemsToProcess();
    }

    private function getLayerType(serviceMetadata:Object, item:PortalItem):String
    {
        var layerType:String;

        if (serviceMetadata.bandCount)
        {
            layerType = ConfigLayer.IMAGE;
        }
        else if (serviceMetadata.singleFusedMapCache)
        {
            layerType = ConfigLayer.TILED;
        }
        else if (isNaN(Number(item.url.charAt(item.url.length - 1))))
        {
            layerType = ConfigLayer.DYNAMIC;
        }
        else
        {
            layerType = ConfigLayer.FEATURE;
        }

        return layerType;
    }

    private function mapServiceMetadataRequest_faultHandler(response:Fault, token:Object = null):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Basemap item service metadata data fetch fault");
        }

        decrementTotalItemsToProcess();
    }

    private function data_resultHandler(decodedObject:Object, basemap:PortalLayer):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Basemap item data fetch success");
        }

        if (decodedObject
            && decodedObject.baseMap
            && decodedObject.baseMap.baseMapLayers
            && decodedObject.baseMap.baseMapLayers.length > 0)
        {
            const url:String = decodedObject.baseMap.baseMapLayers[0].url;
            if (url)
            {
                basemap.serviceURL = url;
                if (decodedObject.baseMap.baseMapLayers.length > 1)
                {
                    basemap.serviceURL2 = decodedObject.baseMap.baseMapLayers[1].url;
                }
                basemaps.push(basemap);
            }
            else
            {
                const type:String = decodedObject.baseMap.baseMapLayers[0].type;
                if (isAllowedType(type))
                {
                    basemap.type = type;
                    basemaps.push(basemap);
                }
            }
        }
        decrementTotalItemsToProcess();
    }

    private function isAllowedType(type:String):Boolean
    {
        return type == "OpenStreetMap" ||
            (isBingBasemap(type) && hasBingKey());
    }

    private function isBingBasemap(type:String):Boolean
    {
        return type.indexOf('BingMaps') > -1;
    }

    private function hasBingKey():Boolean
    {
        var bingKey:String = Model.instance.bingKey;
        return (bingKey != null && bingKey.length > 0);
    }

    private function data_faultHandler(fault:Fault, thumb:PortalLayer):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Basemap item data fetch fault");
        }

        decrementTotalItemsToProcess();
    }

    private function decrementTotalItemsToProcess():void
    {
        totalItemsToProcess--;
        if (totalItemsToProcess === 0)
        {
            dispatchCompleteEvent(orderBasemaps());
        }
    }

    private function orderBasemaps():Array
    {
        const orderedBasemaps:Array = [];
        var basemap:PortalLayer;
        for each (var portalItem:PortalItem in resultItems)
        {
            basemap = findBasemapById(portalItem.id);
            if (basemap)
            {
                orderedBasemaps.push(basemap);
            }
        }

        return orderedBasemaps;
    }

    private function findBasemapById(id:String):PortalLayer
    {
        for each (var basemap:PortalLayer in basemaps)
        {
            if (basemap.id == id)
            {
                return basemap;
            }
        }

        return null;
    }

    private function portalQuery_faultHandler(fault:Fault, token:Object = null):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Portal query fault: {0}", fault.toString());
        }

        dispatchFaultEvent(fault);
    }
}
}
