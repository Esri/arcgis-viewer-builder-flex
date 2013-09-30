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
import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.portal.supportClasses.PortalQueryParameters;
import com.esri.ags.portal.supportClasses.PortalQueryResult;
import com.esri.builder.model.PortalLayer;
import com.esri.builder.supportClasses.LogUtil;

import flash.events.EventDispatcher;

import mx.logging.ILogger;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;
import mx.rpc.events.FaultEvent;

public class PortalSearch extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(PortalSearch);

    protected var portal:Portal;

    public function PortalSearch(portal:Portal)
    {
        this.portal = portal;
    }

    public function execute(queryParams:PortalQueryParameters):void
    {
        LOG.info("Querying Portal: {0}", queryParams.toString());

        portal.queryItems(queryParams,
                          new AsyncResponder(portal_searchResultHandler,
                                             portal_faultHandler));
    }

    private function portal_searchResultHandler(queryResult:PortalQueryResult, token:Object = null):void
    {
        LOG.debug("Processing Portal search results");

        const portalItems:Array = queryResult.results;
        const results:Array = [];

        var portalItem:PortalItem;
        for (var i:uint = 0; i < portalItems.length; i++)
        {
            portalItem = portalItems[i] as PortalItem;
            var portalLayer:PortalLayer = new PortalLayer(portalItem);
            portalLayer.serviceURL = portalItem.url;
            results.push(portalLayer);
        }

        dispatchCompleteEvent(results);
    }

    protected function dispatchCompleteEvent(results:Array):void
    {
        LOG.debug("Portal search complete");

        dispatchEvent(new PortalSearchEvent(PortalSearchEvent.COMPLETE, results));
    }

    private function portal_faultHandler(fault:Fault, token:Object = null):void
    {
        dispatchFaultEvent(fault);
    }

    protected function dispatchFaultEvent(fault:Fault):void
    {
        LOG.debug("Portal search fault: {0}", fault.toString());

        dispatchEvent(new FaultEvent(FaultEvent.FAULT, false, false, fault));
    }
}
}
