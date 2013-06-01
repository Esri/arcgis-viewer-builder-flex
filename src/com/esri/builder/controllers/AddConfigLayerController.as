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

import com.esri.ags.events.LayerEvent;
import com.esri.ags.layers.FeatureLayer;
import com.esri.ags.tasks.JSONTask;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryNode;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.ConfigLayer;
import com.esri.builder.model.ConfigLayerStore;
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.ErrorMessageUtil;
import com.esri.builder.supportClasses.LogUtil;

import flash.net.URLVariables;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;

public final class AddConfigLayerController
{
    private const LOG:ILogger = LogUtil.createLogger(AddConfigLayerController);

    public function AddConfigLayerController()
    {
        AppEvent.addListener(AppEvent.ADD_LAYER_SERVICE, addLayerServiceHandler, false, 0, true);
        AppEvent.addListener(AppEvent.ADD_MAP_SERVICE, addMapServiceHandler, false, 0, true);
    }

    private function addLayerServiceHandler(event:AppEvent):void
    {
        addLayerServer(event.data.layerServer, event.data.configLayerStore);
    }

    private function addMapServiceHandler(event:AppEvent):void
    {
        addMapServer(event.data.mapServer, event.data.configLayerStore);
    }

    private function addLayerServer(layerServer:ServiceDirectoryNode, configLayerStore:ConfigLayerStore):void
    {
        if (Log.isInfo())
        {
            LOG.info("Adding layer server");
        }

        const configLayer:ConfigLayer = new ConfigLayer();
        configLayer.type = ConfigLayer.FEATURE;
        configLayer.label = layerServer.label;
        configLayer.mode = FeatureLayer.MODE_ON_DEMAND;
        configLayer.url = layerServer.url;
        configLayer.visible = true;
        configLayer.alpha = 1.0;

        const urlVars:URLVariables = new URLVariables();
        urlVars.f = 'json';
        const serviceMetadataRequest:JSONTask = new JSONTask(layerServer.url);
        serviceMetadataRequest.requestTimeout = Model.REQUEST_TIMEOUT;
        serviceMetadataRequest.showBusyCursor = true;
        serviceMetadataRequest.execute(urlVars,
                                       new AsyncResponder(serviceMetadataRequest_resultHandler,
                                                          serviceMetadataRequest_faultHandler,
                                                          configLayer));

        function serviceMetadataRequest_resultHandler(serviceMetadata:Object, configLayer:ConfigLayer):void
        {
            if (Log.isDebug())
            {
                LOG.debug("Layer server metadata success");
            }

            if (serviceMetadata.fields && serviceMetadata.fields.length > 0)
            {
                if (Log.isDebug())
                {
                    LOG.debug("Layer server has fields");
                }

                configLayerStore.addLayer(configLayer);
                assignAdditionalFeatureLayerProperties(configLayer);
            }
            else
            {
                const errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                    'mapsView.couldNotAddAsFeatureLayer',
                                                                                    [ configLayer.label ]);
                AppEvent.dispatch(AppEvent.SHOW_ERROR, errorMessage);
            }
        }

        function serviceMetadataRequest_faultHandler(fault:Fault, configLayer:ConfigLayer):void
        {
            if (Log.isDebug())
            {
                LOG.debug("Layer server metadata fault");
            }

            const errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                'mapsView.couldNotAddLayer',
                                                                                [ configLayer.label, ErrorMessageUtil.getKnownErrorCauseMessage(fault)]);
            AppEvent.dispatch(AppEvent.SHOW_ERROR, errorMessage);
        }
    }

    private function assignAdditionalFeatureLayerProperties(configLayer:ConfigLayer):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Fetching additional feature layer proeprties");
        }

        const featureLayer:FeatureLayer = configLayer.createLayer() as FeatureLayer;
        featureLayer.addEventListener(LayerEvent.LOAD, featureLayer_loadHandler);
        featureLayer.addEventListener(LayerEvent.LOAD_ERROR, featureLayer_loadErrorHandler);

        function featureLayer_loadHandler(event:LayerEvent):void
        {
            if (Log.isDebug())
            {
                LOG.debug("Feature layer load");
            }

            removeFeatureLayerListeners();

            const supportedQueryFormats:Array = featureLayer.layerDetails.supportedQueryFormats;
            const useAMF:Boolean = (supportedQueryFormats && (supportedQueryFormats.indexOf("AMF") >= 0))
                || (featureLayer.layerDetails.version >= 10);

            configLayer.useAMF = useAMF;
            AppEvent.dispatch(AppEvent.LAYER_SERVICE_ADDED);
            if (Log.isDebug())
            {
                LOG.debug("Service layer added");
            }
        }

        function featureLayer_loadErrorHandler(event:LayerEvent):void
        {
            if (Log.isDebug())
            {
                LOG.debug("Feature layer load error");
            }

            removeFeatureLayerListeners();
            if (Log.isDebug())
            {
                LOG.debug("Service layer added");
            }

            AppEvent.dispatch(AppEvent.LAYER_SERVICE_ADDED);
        }

        function removeFeatureLayerListeners():void
        {
            featureLayer.removeEventListener(LayerEvent.LOAD, featureLayer_loadHandler);
            featureLayer.removeEventListener(LayerEvent.LOAD_ERROR, featureLayer_loadErrorHandler);
        }
    }

    private function addMapServer(mapServer:ServiceDirectoryNode, configLayerStore:ConfigLayerStore):void
    {
        if (Log.isInfo())
        {
            LOG.info("Adding map server");
        }

        if (mapServer.metadata)
        {
            if (Log.isDebug())
            {
                LOG.debug("Creating map server from metadata");
            }

            createAndAddMapServiceConfigLayer(mapServer, configLayerStore);
        }
        else
        {
            if (Log.isDebug())
            {
                LOG.debug("Fetching map server metadata");
            }

            const urlVars:URLVariables = new URLVariables();
            urlVars.f = 'json';
            const serviceMetadataRequest:JSONTask = new JSONTask(mapServer.url);
            serviceMetadataRequest.requestTimeout = Model.REQUEST_TIMEOUT;
            serviceMetadataRequest.showBusyCursor = true;
            serviceMetadataRequest.execute(urlVars,
                                           new AsyncResponder(serviceMetadataRequest_resultHandler,
                                                              serviceMetadataRequest_faultHandler));

            function serviceMetadataRequest_resultHandler(serviceMetadata:Object, token:Object = null):void
            {
                if (Log.isDebug())
                {
                    LOG.debug("Fetch map server metadata success");
                }

                mapServer.metadata = serviceMetadata;
                createAndAddMapServiceConfigLayer(mapServer, configLayerStore);
            }

            function serviceMetadataRequest_faultHandler(fault:Fault, token:Object = null):void
            {
                if (Log.isDebug())
                {
                    LOG.debug("Fetch map server metadata fault");
                }

                const errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                                    'mapsView.couldNotAddLayer',
                                                                                    [ mapServer.label, ErrorMessageUtil.getKnownErrorCauseMessage(fault)]);
                AppEvent.dispatch(AppEvent.SHOW_ERROR, errorMessage);
            }
        }
    }

    private function createAndAddMapServiceConfigLayer(mapServer:ServiceDirectoryNode, configLayerStore:ConfigLayerStore):void
    {
        const configLayer:ConfigLayer = new ConfigLayer();

        if (mapServer.metadata.bandCount)
        {
            configLayer.type = ConfigLayer.IMAGE;
        }
        else if (mapServer.metadata.singleFusedMapCache)
        {
            configLayer.type = ConfigLayer.TILED;
        }
        else
        {
            configLayer.type = ConfigLayer.DYNAMIC;
        }

        configLayer.label = mapServer.label;
        configLayer.url = mapServer.url;
        configLayer.visible = true;
        configLayer.alpha = 1.0;

        if (Log.isDebug())
        {
            LOG.debug("Add config layer - label: {0}, type: {1}, url: {2}", configLayer.label, configLayer.type, configLayer.url);
        }

        configLayerStore.addLayer(configLayer);
        AppEvent.dispatch(AppEvent.MAP_SERVICE_ADDED);
    }
}
}
