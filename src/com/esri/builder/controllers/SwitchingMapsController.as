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
package com.esri.builder.controllers
{

import com.esri.ags.Map;
import com.esri.ags.events.WebMapEvent;
import com.esri.ags.geometry.Extent;
import com.esri.ags.layers.CSVLayer;
import com.esri.ags.layers.FeatureLayer;
import com.esri.ags.layers.Layer;
import com.esri.ags.layers.WebTiledLayer;
import com.esri.ags.layers.supportClasses.TileInfo;
import com.esri.ags.portal.WebMapUtil;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.ConfigLayer;
import com.esri.builder.model.ConfigMap;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalModel;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.popups.NoticePopUp;

import flash.display.DisplayObject;
import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import mx.utils.ObjectUtil;

public final class SwitchingMapsController
{
    private static const LOG:ILogger = LogUtil.createLogger(SwitchingMapsController);

    private var doNotShowLayerNotAddedPopUp:Boolean;
    private var isCreatingLayersFromWebMap:Boolean;
    private var webMapUtil:WebMapUtil;
    private var mapConfigXML:XML;
    private var noticePopUp:NoticePopUp;

    public function SwitchingMapsController()
    {
        AppEvent.addListener(AppEvent.SWITCH_MAPS, onSwitchMaps, false, 0, true);
        AppEvent.addListener(AppEvent.CONFIG_XML_SAVED, configXMLSaved, false, 0, true);

        webMapUtil = new WebMapUtil();
        webMapUtil.ignorePopUps = true;
        webMapUtil.addEventListener(WebMapEvent.CREATE_MAP_BY_ID_COMPLETE, createMapByIdCompleteHandler);
    }

    private function onSwitchMaps(event:AppEvent):void
    {
        if (event.data == "webmap")
        {
            if (Model.instance.config.configMap.basemaps.hasLayers
                || Model.instance.config.configMap.operationalLayers.hasLayers)
            {
                showNoticePopUp("webmap", ResourceManager.getInstance().getString("BuilderStrings", "noticePopUp.basemapsToWebmapContent"));
            }
            else
            {
                AppEvent.dispatch(AppEvent.MAPS_SWITCHED, "webmap");
            }
        }
        else if (event.data == "layers")
        {
            if (Model.instance.config.configMap && Model.instance.config.configMap.itemId)
            {
                showNoticePopUp("layers", ResourceManager.getInstance().getString("BuilderStrings", "noticePopUp.webMapToBasemapsContent"), true);
            }
            else
            {
                AppEvent.dispatch(AppEvent.MAPS_SWITCHED, "layers");
            }
        }
    }

    private function showNoticePopUp(newView:String, content:String, showBusyCursor:Boolean = false):void
    {
        noticePopUp = new NoticePopUp();
        noticePopUp.newView = newView;
        noticePopUp.content = content;
        noticePopUp.showBusyCursor = showBusyCursor;
        noticePopUp.addEventListener("isWaitingChanged", isWaitingChangedHandler);
        noticePopUp.addEventListener(CloseEvent.CLOSE, noticePopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(noticePopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(noticePopUp);
    }

    private function isWaitingChangedHandler(event:Event):void
    {
        noticePopUp.removeEventListener("isWaitingChanged", isWaitingChangedHandler);
        if (noticePopUp.isWaiting)
        {
            createBasemapsAndOperationalLayersFromWebMap();
        }
    }

    private function noticePopUp_closeHandler(event:CloseEvent):void
    {
        var noticePopUp:NoticePopUp = event.currentTarget as NoticePopUp;
        if (noticePopUp.changeView)
        {
            if (noticePopUp.newView == "webmap")
            {
                AppEvent.dispatch(AppEvent.MAPS_SWITCHED, "webmap");
            }
        }
        noticePopUp.removeEventListener(CloseEvent.CLOSE, noticePopUp_closeHandler);
        PopUpManager.removePopUp(event.currentTarget as NoticePopUp);
        noticePopUp = null;
    }

    private function createBasemapsAndOperationalLayersFromWebMap():void
    {
        LOG.info("creating basemap & op layers from web map");

        var webMapId:String = Model.instance.config.configMap.itemId;

        webMapUtil.portalURL = PortalModel.getInstance().portalURL;
        webMapUtil.proxyURL = Model.instance.proxyURL;
        webMapUtil.createMapById(webMapId);
    }

    private function createMapByIdCompleteHandler(event:WebMapEvent):void
    {
        isCreatingLayersFromWebMap = true;

        var map:Map = event.map;

        var unsupportedLayers:Array = []

        var title:String = event.item.title;

        var initialextent:String;
        var extent:Extent = map.extent;
        if (extent)
        {
            var extentArr:Array = [ extent.xmin, extent.ymin, extent.xmax, extent.ymax ];
            initialextent = extentArr.join(" ");
        }

        XML.ignoreComments = false;
        XML.ignoreWhitespace = false;
        XML.prettyIndent = 4;

        mapConfigXML = <map initialextent={initialextent} top="40" wraparound180="true" addarcgisbasemaps={Model.instance.config.configMap.addArcGISBasemaps}/>
        if (!extent)
        {
            delete mapConfigXML.map.@initialextent;
        }

        var baseMapTitle:String;
        if (event.itemData.baseMap)
        {
            baseMapTitle = event.itemData.baseMap.title;
        }

        var baseLayers:XML = <basemaps/>;
        var opLayers:XML = <operationallayers/>;

        var supportedTileInfo:TileInfo;
        var layers:Array = (map.layers as ArrayCollection).toArray();
        for (var i:int = 0; i < layers.length; i++)
        {
            var layer:Layer = layers[i];

            if (layer is FeatureLayer && !(layer is CSVLayer))
            {
                var feaLyr:FeatureLayer = layer as FeatureLayer;
                if (feaLyr.featureCollection)
                {
                    unsupportedLayers.push(layer.name);
                    map.removeLayer(layer);
                    continue;
                }
                else
                {
                    for each (var layerObject:Object in event.itemData.operationalLayers)
                    {
                        if (layerObject.title == feaLyr.name
                            && layerObject.url == feaLyr.url)
                        {
                            feaLyr.isEditable = !layerObject.capabilities ||
                                layerObject.capabilities.indexOf("Editing") != -1;
                            break;
                        }
                    }
                }
            }
            if (layer is WebTiledLayer)
            {
                var webTiledLayer:WebTiledLayer = layer as WebTiledLayer;
                if (!supportedTileInfo)
                {
                    supportedTileInfo = new WebTiledLayer().tileInfo;
                }
                var hasSupportedTileInfo:Boolean = ObjectUtil.compare(supportedTileInfo, webTiledLayer.tileInfo) == 0;
                if (!hasSupportedTileInfo)
                {
                    unsupportedLayers.push(layer.name);
                    map.removeLayer(layer);
                    continue;
                }
            }

            var isOpLayer:Boolean = layer.id.indexOf("base") != 0;
            var lyrXML:XML;

            if (isOpLayer)
            {
                lyrXML = ConfigLayer.operationalLayerToXML(layer, layer.name);
                if (lyrXML)
                {
                    opLayers.appendChild(lyrXML);
                }
            }
            else
            {
                if (!baseMapTitle && i == 0)
                {
                    baseMapTitle = layer.name;
                }

                lyrXML = ConfigLayer.basemapLayerToXML(layer, baseMapTitle);
                if (lyrXML)
                {
                    if (opLayers.children().length() > 0)
                    {
                        lyrXML.@reference = true;
                    }

                    baseLayers.appendChild(lyrXML);
                }
            }
        }

        mapConfigXML.appendChild(baseLayers);

        if (opLayers.hasComplexContent())
        {
            mapConfigXML.appendChild(opLayers);
        }
        if (unsupportedLayers.length)
        {
            noticePopUp.isWaiting = false;
            showLayerNotAddedPopUp(unsupportedLayers);
        }
        else
        {
            saveNewMapConfig();
        }
    }

    private function showLayerNotAddedPopUp(layerNames:Array):void
    {
        var layerNotAddedPopUp:NoticePopUp = new NoticePopUp;
        var content:String = ResourceManager.getInstance().getString("BuilderStrings", "mapsView.convertWebMapToLayers.layersNotAdded");
        content += "\n";
        for each (var layerName:String in layerNames)
        {
            content += "   " + layerName + "\n"
        }
        content += ResourceManager.getInstance().getString("BuilderStrings", "mapsView.convertWebMapToLayers.doYouWantToContinue");
        layerNotAddedPopUp.content = content;
        layerNotAddedPopUp.addEventListener(CloseEvent.CLOSE, layerNotAddedPopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(layerNotAddedPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(layerNotAddedPopUp);
    }

    private function layerNotAddedPopUp_closeHandler(event:CloseEvent):void
    {
        var layerNotAddedPopUp:NoticePopUp = event.currentTarget as NoticePopUp;
        if (layerNotAddedPopUp.changeView)
        {
            saveNewMapConfig();
        }
        layerNotAddedPopUp.removeEventListener(CloseEvent.CLOSE, noticePopUp_closeHandler);
        PopUpManager.removePopUp(event.currentTarget as NoticePopUp);
        layerNotAddedPopUp = null;
    }

    private function saveNewMapConfig():void
    {
        if (noticePopUp)
        {
            noticePopUp.isWaiting = false;
            if (noticePopUp.changeView)
            {
                saveNewMapConfig2();
            }
        }
        else
        {
            saveNewMapConfig2();
        }
    }

    private function saveNewMapConfig2():void
    {
        LOG.debug("converting map XML {0}", mapConfigXML.toXMLString());

        Model.instance.config.configMap = ConfigMap.decodeXML(mapConfigXML);
        Model.instance.configBasemapsList.importLayers(Model.instance.config.configMap.basemaps.getAllLayers());
        Model.instance.configOpsLayerList.importLayers(Model.instance.config.configMap.operationalLayers.getAllLayers());
        AppEvent.dispatch(AppEvent.SAVE_CONFIG_XML);
    }

    private function configXMLSaved(event:AppEvent):void
    {
        if (isCreatingLayersFromWebMap)
        {
            Model.instance.webmap = null;
            Model.instance.webMapConfigBasemapList.removeAllLayers();
            Model.instance.webMapConfigOpLayerList.removeAllLayers();
            isCreatingLayersFromWebMap = false;
            AppEvent.dispatch(AppEvent.MAPS_SWITCHED, "layers");
        }
    }
}

}
