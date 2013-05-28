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

import com.esri.ags.components.IdentityManager;
import com.esri.ags.components.supportClasses.Credential;
import com.esri.ags.tasks.JSONTask;
import com.esri.builder.components.serviceBrowser.filters.GPTaskFilter;
import com.esri.builder.components.serviceBrowser.filters.GeocoderFilter;
import com.esri.builder.components.serviceBrowser.filters.INodeFilter;
import com.esri.builder.components.serviceBrowser.filters.MapLayerFilter;
import com.esri.builder.components.serviceBrowser.filters.QueryableLayerFilter;
import com.esri.builder.components.serviceBrowser.filters.RouteLayerFilter;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryRootNode;
import com.esri.builder.model.Model;
import com.esri.builder.components.serviceBrowser.supportClasses.ServiceDirectoryBuildRequest;
import com.esri.builder.supportClasses.LogUtil;

import flash.events.EventDispatcher;
import flash.net.URLVariables;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import com.esri.builder.components.serviceBrowser.filters.MapServerFilter;

public final class ServiceDirectoryBuilder extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(ServiceDirectoryBuilder);

    private static const DEFAULT_REQUEST_TIMEOUT_IN_SECONDS:Number = 10;

    private var count:int;
    private var searchType:String;

    private var hasCrossDomain:Boolean;
    private var crossDomainRequest:HTTPService;
    private var credential:Credential;
    private var rootNode:ServiceDirectoryRootNode;
    private var currentNodeFilter:INodeFilter;
    private var isServiceSecured:Boolean;
    private var securityWarning:String;
    private var owningSystemURL:String;

    public function buildServiceDirectory(serviceDirectoryBuildRequest:ServiceDirectoryBuildRequest):void
    {
        if (Log.isInfo())
        {
            LOG.info("Building service directory");
        }

        try
        {
            checkCrossDomainBeforeBuildingDirectory(serviceDirectoryBuildRequest);
        }
        catch (error:Error)
        {
            //TODO: handle error
        }
    }

    private function checkCrossDomainBeforeBuildingDirectory(serviceDirectoryBuildRequest:ServiceDirectoryBuildRequest):void
    {
        if (Log.isDebug())
        {
            LOG.debug("Checking service URL crossdomain.xml");
        }

        crossDomainRequest = new HTTPService();
        crossDomainRequest.url = extractCrossDomainPolicyFileURL(serviceDirectoryBuildRequest.url);
        crossDomainRequest.addEventListener(ResultEvent.RESULT, crossDomainRequest_resultHandler);
        crossDomainRequest.addEventListener(FaultEvent.FAULT, crossDomainRequest_faultHandler);
        crossDomainRequest.requestTimeout = DEFAULT_REQUEST_TIMEOUT_IN_SECONDS;
        crossDomainRequest.send();

        function crossDomainRequest_resultHandler(event:ResultEvent):void
        {
            if (Log.isDebug())
            {
                LOG.debug("Found service crossdomain.xml");
            }

            crossDomainRequest.removeEventListener(ResultEvent.RESULT, crossDomainRequest_resultHandler);
            crossDomainRequest.removeEventListener(FaultEvent.FAULT, crossDomainRequest_faultHandler);
            crossDomainRequest = null;
            hasCrossDomain = true;

            checkIfServiceIsSecure(serviceDirectoryBuildRequest);
        }

        function crossDomainRequest_faultHandler(event:FaultEvent):void
        {
            if (Log.isDebug())
            {
                LOG.debug("Could not find service crossdomain.xml");
            }

            crossDomainRequest.removeEventListener(ResultEvent.RESULT, crossDomainRequest_resultHandler);
            crossDomainRequest.removeEventListener(FaultEvent.FAULT, crossDomainRequest_faultHandler);
            crossDomainRequest = null;
            hasCrossDomain = false;

            checkIfServiceIsSecure(serviceDirectoryBuildRequest);
        }
    }

    private function extractCrossDomainPolicyFileURL(url:String):String
    {
        var baseURL:RegExp = /(https?:\/\/)([^\/]+\/)/
        var baseURLMatch:Array = url.match(baseURL);
        return baseURLMatch[0] + 'crossdomain.xml';
    }

    private function checkIfServiceIsSecure(serviceDirectoryBuildRequest:ServiceDirectoryBuildRequest):void
    {
        if (Log.isInfo())
        {
            LOG.info("Checking if service is secure");
        }

        var serviceSecurityRequest:JSONTask = new JSONTask();
        serviceSecurityRequest.url = extractServiceInfoURL(serviceDirectoryBuildRequest.url);
        const param:URLVariables = new URLVariables();
        param.f = 'json';
        serviceSecurityRequest.execute(param, new AsyncResponder(serviceSecurityRequest_resultHandler, serviceSecurityRequest_faultHandler));

        function serviceSecurityRequest_resultHandler(serverInfo:Object, token:Object = null):void
        {
            isServiceSecured = (serverInfo.currentVersion >= 10.01
                && serverInfo.authInfo
                && serverInfo.authInfo.isTokenBasedSecurity);

            owningSystemURL = serverInfo.owningSystemUrl;

            if (isServiceSecured)
            {
                if (Log.isDebug())
                {
                    LOG.debug("Service is secure");
                }

                if (Log.isDebug())
                {
                    LOG.debug("Checking token service crossdomain.xml");
                }

                const tokenServiceCrossDomainRequest:HTTPService = new HTTPService();
                tokenServiceCrossDomainRequest.url = extractCrossDomainPolicyFileURL(serverInfo.authInfo.tokenServicesUrl);
                tokenServiceCrossDomainRequest.resultFormat = HTTPService.RESULT_FORMAT_E4X;
                tokenServiceCrossDomainRequest.addEventListener(ResultEvent.RESULT, tokenServiceSecurityRequest_resultHandler);
                tokenServiceCrossDomainRequest.addEventListener(FaultEvent.FAULT, tokenServiceSecurityRequest_faultHandler);
                tokenServiceCrossDomainRequest.send();

                function tokenServiceSecurityRequest_resultHandler(event:ResultEvent):void
                {
                    if (Log.isDebug())
                    {
                        LOG.debug("Found token service crossdomain.xml");
                    }

                    tokenServiceCrossDomainRequest.removeEventListener(ResultEvent.RESULT, tokenServiceSecurityRequest_resultHandler);
                    tokenServiceCrossDomainRequest.removeEventListener(FaultEvent.FAULT, tokenServiceSecurityRequest_faultHandler);

                    const startsWithHTTPS:RegExp = /^https/;
                    if (startsWithHTTPS.test(tokenServiceCrossDomainRequest.url))
                    {
                        const tokenServiceCrossDomainXML:XML = event.result as XML;
                        const hasSecurityEnabled:Boolean =
                            tokenServiceCrossDomainXML.child("allow-access-from").(attribute("secure") == "false").length() == 0
                            || tokenServiceCrossDomainXML.child("allow-http-request-headers-from").(attribute("secure") == "false").length() == 0;

                        if (hasSecurityEnabled
                            && !startsWithHTTPS.test(Model.instance.appDir.url))
                        {
                            securityWarning = ResourceManager.getInstance().getString('BuilderStrings', 'serviceBrowser.secureTokenServiceWithSecureCrossDomain');
                        }
                    }
                }

                function tokenServiceSecurityRequest_faultHandler(event:FaultEvent):void
                {
                    if (Log.isDebug())
                    {
                        LOG.debug("Could not find token service crossdomain.xml");
                    }

                    tokenServiceCrossDomainRequest.removeEventListener(ResultEvent.RESULT, tokenServiceSecurityRequest_resultHandler);
                    tokenServiceCrossDomainRequest.removeEventListener(FaultEvent.FAULT, tokenServiceSecurityRequest_faultHandler);
                    securityWarning = ResourceManager.getInstance().getString('BuilderStrings', 'serviceBrowser.secureTokenServiceMissingCrossDomain');
                }
            }

            //continue with building service directory
            startBuildingDirectory(serviceDirectoryBuildRequest);
        }

        function serviceSecurityRequest_faultHandler(fault:Fault, token:Object = null):void
        {
            //continue with building service directory
            startBuildingDirectory(serviceDirectoryBuildRequest);
        }
    }

    private function extractServiceInfoURL(url:String):String
    {
        return url.replace('/rest/services', '/rest/info');
    }

    private function startBuildingDirectory(serviceDirectoryBuildRequest:ServiceDirectoryBuildRequest):void
    {
        if (Log.isInfo())
        {
            LOG.info('Building serviced directory {0}', serviceDirectoryBuildRequest.url);
        }

        const servicesDirectoryURL:RegExp = /.+\/rest\/services\/?/;
        const serviceURLRootMatch:Array = servicesDirectoryURL.exec(serviceDirectoryBuildRequest.url);

        if (!serviceURLRootMatch)
        {
            return;
        }

        currentNodeFilter = filterFromSearchType(serviceDirectoryBuildRequest.searchType);
        rootNode = new ServiceDirectoryRootNode(serviceDirectoryBuildRequest.url, currentNodeFilter);
        rootNode.addEventListener(URLNodeTraversalEvent.END_REACHED, rootNode_completeHandler);
        rootNode.addEventListener(FaultEvent.FAULT, rootNode_faultHandler);
        credential = IdentityManager.instance.findCredential(serviceURLRootMatch[0]);
        if (credential)
        {
            rootNode.token = credential.token;
        }
        rootNode.loadChildren();
    }

    private function filterFromSearchType(searchType:String):INodeFilter
    {
        if (searchType == ServiceDirectoryBuildRequest.QUERYABLE_LAYER_SEARCH)
        {
            return new QueryableLayerFilter();
        }
        else if (searchType == ServiceDirectoryBuildRequest.GEOPROCESSING_TASK_SEARCH)
        {
            return new GPTaskFilter();
        }
        else if (searchType == ServiceDirectoryBuildRequest.GEOCODER_SEARCH)
        {
            return new GeocoderFilter();
        }
        else if (searchType == ServiceDirectoryBuildRequest.ROUTE_LAYER_SEARCH)
        {
            return new RouteLayerFilter();
        }
        else if (searchType == ServiceDirectoryBuildRequest.MAP_SERVER_SEARCH)
        {
            return new MapServerFilter();
        }
        else //MAP LAYER SEARCH
        {
            return new MapLayerFilter();
        }
    }

    private function rootNode_completeHandler(event:URLNodeTraversalEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info("Finished building service directory");
        }

        dispatchEvent(
            new ServiceDirectoryBuilderEvent(ServiceDirectoryBuilderEvent.COMPLETE,
                                             new ServiceDirectoryInfo(rootNode,
                                                                      event.urlNodes,
                                                                      currentNodeFilter,
                                                                      hasCrossDomain,
                                                                      isServiceSecured,
                                                                      securityWarning,
                                                                      owningSystemURL)));
    }

    protected function rootNode_faultHandler(event:FaultEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info("Could not build service directory");
        }

        dispatchEvent(event);
    }
}
}
