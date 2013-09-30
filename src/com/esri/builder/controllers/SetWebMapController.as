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
import com.esri.ags.components.IdentityManager;
import com.esri.ags.events.IdentityManagerEvent;
import com.esri.ags.events.WebMapEvent;
import com.esri.ags.layers.Layer;
import com.esri.ags.portal.Portal;
import com.esri.ags.portal.WebMapUtil;
import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.virtualearth.VETiledLayer;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.ConfigLayer;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalModel;
import com.esri.builder.supportClasses.ErrorMessageUtil;
import com.esri.builder.supportClasses.LogUtil;

import mx.controls.Alert;
import mx.logging.ILogger;
import mx.managers.CursorManager;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

public final class SetWebMapController
{
    private static const LOG:ILogger = LogUtil.createLogger(SetWebMapController);

    private var webMapUtil:WebMapUtil;

    public function SetWebMapController()
    {
        AppEvent.addListener(AppEvent.SETTINGS_SAVED, settingsSavedHandler);
        AppEvent.addListener(AppEvent.SET_WEB_MAP, setWebMapHandler, false, 0, true);
        AppEvent.addListener(AppEvent.LOAD_WEB_MAP, loadWebMapHandler, false, 0, true);

        webMapUtil = new WebMapUtil();
    }

    private function settingsSavedHandler(event:AppEvent):void
    {
        if (PortalModel.getInstance().portalURL)
        {
            webMapUtil.portalURL = PortalModel.getInstance().portalURL;
        }
    }

    private function setWebMapHandler(event:AppEvent):void
    {
        var webmap:PortalItem = event.data as PortalItem;

        LOG.info('Setting web map to id {0}', webmap.id);

        // Check if the basemap has a bing key before selecting it as the selected webmap.
        webMapUtil.createMapById(webmap.id, new AsyncResponder(bingKeyCheck_resultHandler,
                                                               bingKeyCheck_faultHandler,
                                                               webmap));

        // CR 255,407: listen if the IdentityManager popup the sign in window to temporary remove the busy cursor.
        IdentityManager.instance.addEventListener(IdentityManagerEvent.SHOW_SIGN_IN_WINDOW, showSignInWindowHandler);
        CursorManager.setBusyCursor();
    }

    private function bingKeyCheck_resultHandler(result:WebMapEvent, webmap:PortalItem):void
    {
        // CR 255,407
        IdentityManager.instance.removeEventListener(IdentityManagerEvent.SHOW_SIGN_IN_WINDOW, showSignInWindowHandler);
        CursorManager.removeBusyCursor();

        var bingLayer:VETiledLayer;
        var hasBingLayer:Boolean;
        var hasBingKey:Boolean = Boolean(Model.instance.bingKey);
        for each (var layer:Layer in result.map.layers)
        {
            bingLayer = layer as VETiledLayer;
            if (bingLayer)
            {
                hasBingLayer = true;

                if (hasBingKey)
                {
                    break;
                }
                else if (bingLayer.key)
                {
                    hasBingKey = true;
                    break;
                }
            }
        }

        var canProceedWithoutBingKey:Boolean = !hasBingLayer || hasBingKey;
        if (canProceedWithoutBingKey)
        {
            setWebMap(webmap, result.map);
        }
        else
        {
            var resourceManager:IResourceManager = ResourceManager.getInstance();
            Alert.show(resourceManager.getString("BuilderStrings", "mapsView.noBingkeyAlertContent"),
                       resourceManager.getString("BuilderStrings", "mapsView.noBingkeyAlertTitle"));
        }
    }

    private function bingKeyCheck_faultHandler(fault:Fault, webmap:PortalItem):void
    {
        // CR 255,407
        IdentityManager.instance.removeEventListener(IdentityManagerEvent.SHOW_SIGN_IN_WINDOW, showSignInWindowHandler);
        CursorManager.removeBusyCursor();
        AppEvent.dispatch(AppEvent.SHOW_ERROR,
                          ErrorMessageUtil.getKnownErrorCauseMessage(fault));
    }

    private function setWebMap(webmap:PortalItem, map:Map):void
    {
        LOG.info('Setting web map to id {0}', webmap.id);

        Model.instance.config.isDirty = true;
        Model.instance.webmap = webmap;
        Model.instance.config.appTitle = webmap.title;

        Model.instance.webMapConfigBasemapList.removeAllLayers();
        Model.instance.webMapConfigOpLayerList.removeAllLayers();

        importConfigLayersFromMap(map);

        Model.instance.config.configMap.itemId = webmap.id;

        Model.instance.config.configMap.initExtent = null;
        Model.instance.config.configMap.lods = [];

        Model.instance.configBasemapsList.removeAllLayers();
        Model.instance.configOpsLayerList.removeAllLayers();

        Model.instance.config.configMap.basemaps.removeAllLayers();
        Model.instance.config.configMap.operationalLayers.removeAllLayers();
    }

    private function setWebMapConfigLayers(id:String):void
    {
        LOG.debug('Creating config layers for web map: {0}', id);

        Model.instance.webMapConfigBasemapList.removeAllLayers();
        Model.instance.webMapConfigOpLayerList.removeAllLayers();

        webMapUtil.addEventListener(WebMapEvent.CREATE_MAP_BY_ID_COMPLETE, webMapUtil_createMapByIDHandler);
        webMapUtil.addEventListener(FaultEvent.FAULT, webMapUtil_faultHandler);
        webMapUtil.createMapById(id);
    }

    private function webMapUtil_createMapByIDHandler(event:WebMapEvent):void
    {
        LOG.debug('Create map by ID success');

        webMapUtil.removeEventListener(WebMapEvent.CREATE_MAP_BY_ID_COMPLETE, webMapUtil_createMapByIDHandler);
        webMapUtil.removeEventListener(FaultEvent.FAULT, webMapUtil_faultHandler);

        importConfigLayersFromMap(event.map);
    }

    private function importConfigLayersFromMap(map:Map):void
    {
        var isOpLayer:Boolean;
        for each (var layer:Layer in map.layers)
        {
            isOpLayer = layer.id.indexOf("base") != 0;
            if (isOpLayer)
            {
                LOG.debug('Storing basemap config layer');

                Model.instance.webMapConfigOpLayerList.addLayer(
                    ConfigLayer.operationalConfigLayerFromLayer(layer, layer.name));
            }
            else
            {
                LOG.debug('Storing operational config layer');

                Model.instance.webMapConfigBasemapList.addLayer(
                    ConfigLayer.basemapConfigLayerFromLayer(layer, layer.name));
            }
        }
    }

    private function webMapUtil_faultHandler(event:FaultEvent):void
    {
        LOG.debug('Create map by ID fault');

        webMapUtil.removeEventListener(WebMapEvent.CREATE_MAP_BY_ID_COMPLETE, webMapUtil_createMapByIDHandler);
        webMapUtil.removeEventListener(FaultEvent.FAULT, webMapUtil_faultHandler);
    }

    private function loadWebMapHandler(event:AppEvent):void
    {
        const itemId:String = Model.instance.config.configMap.itemId;
        if (itemId)
        {
            LOG.info('Loading web map: {0}', itemId);

            var portal:Portal = PortalModel.getInstance().portal;

            if (!portal.loaded)
            {
                const portalNotLoadedMessage:String = ResourceManager.getInstance().getString('BuilderStrings', 'agsPortal.requiresPortal');
                const couldNotLoadWebMapMessage:String = ResourceManager.getInstance().getString('BuilderStrings', 'setWebMap.couldNotLoadWebMap',
                                                                                                 [ portalNotLoadedMessage ]);
                AppEvent.dispatch(AppEvent.SHOW_ERROR, couldNotLoadWebMapMessage);
                return;
            }

            portal.getItem(itemId, new AsyncResponder(resultHandler, faultHandler));

            function resultHandler(portalItem:PortalItem, token:Object = null):void
            {
                LOG.debug("Web map item fetch success");

                if (portal.user) // always show my content first when logged in
                {
                    Model.instance.webmapState = "mycontent";
                }
                Model.instance.webmap = portalItem;
                setWebMapConfigLayers(itemId);
                Model.instance.appState = 'viewer';
                Model.instance.status = '';
            }

            function faultHandler(fault:Fault, token:Object = null):void
            {
                LOG.debug("Web map item fetch fault");

                Model.instance.webmap = null;
                Model.instance.webMapConfigBasemapList.removeAllLayers();
                Model.instance.webMapConfigOpLayerList.removeAllLayers();

                LOG.error(ResourceManager.getInstance().getString('BuilderStrings', 'setWebMap.couldNotLoadWebMap',
                                                                  [ fault.toString()]));

                AppEvent.dispatch(AppEvent.SHOW_ERROR,
                                  ResourceManager.getInstance().getString('BuilderStrings',
                                                                          'setWebMap.couldNotLoadWebMap',
                                                                          [ fault.faultString ]));
            }
        }
        else
        {
            Model.instance.webmap = null;
            Model.instance.webMapConfigBasemapList.removeAllLayers();
            Model.instance.webMapConfigOpLayerList.removeAllLayers();
            Model.instance.appState = 'viewer';
            Model.instance.status = '';
        }
    }

    private function showSignInWindowHandler(event:IdentityManagerEvent):void
    {
        CursorManager.removeBusyCursor();
    }
}

}
