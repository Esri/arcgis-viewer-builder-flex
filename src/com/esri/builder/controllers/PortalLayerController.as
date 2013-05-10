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

import com.esri.ags.portal.Portal;
import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.portal.supportClasses.PortalQueryParameters;
import com.esri.ags.portal.supportClasses.PortalUser;
import com.esri.builder.controllers.supportClasses.PortalBasemapGallerySearch;
import com.esri.builder.controllers.supportClasses.PortalSearch;
import com.esri.builder.controllers.supportClasses.PortalSearchEvent;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalModel;

import flash.net.SharedObject;

import mx.collections.ArrayList;
import mx.rpc.events.FaultEvent;

public final class PortalLayerController
{
    private var portal:Portal;
    private var searchTerm:String;
    private var isLoggingIn:Boolean;
    private var user:PortalUser;

    private var currentPortalSearch:PortalSearch;

    private var currentPortalBasemapGallerySearch:PortalBasemapGallerySearch;

    public function PortalLayerController()
    {
        AppEvent.addListener(AppEvent.PORTAL_LAYER_SEARCH, portalLayerSearchHandler, false, 0, true);
        portal = PortalModel.getInstance().portal;
    }

    private function portalLayerSearchHandler(event:AppEvent):void
    {
        searchTerm = event.data.searchTerm as String;
        isLoggingIn = event.data.isLoggingIn as Boolean;
        user = event.data.user as PortalUser;
        portalLayerSearch(searchTerm);
    }

    private function portalLayerSearch(searchTerm:String):void
    {
        if (searchTerm)
        {
            searchArcGISPortal(searchTerm);
        }
        else
        {
            loadBasemapsGroup();
        }
    }

    private function searchArcGISPortal(searchTerm:String):void
    {
        if (!portal.loaded)
        {
            return;
        }

        Model.instance.portalLayersState = 'searchloading';
        var queryParams:PortalQueryParameters = buildLayersQueryParameters(searchTerm);

        if (currentPortalSearch)
        {
            currentPortalSearch.removeEventListener(PortalSearchEvent.COMPLETE, portalSearch_completeHandler);
            currentPortalSearch.removeEventListener(FaultEvent.FAULT, portalSearch_faultHandler);
        }
        currentPortalSearch = new PortalSearch(portal);
        currentPortalSearch.addEventListener(PortalSearchEvent.COMPLETE, portalSearch_completeHandler, false, 0, true);
        currentPortalSearch.addEventListener(FaultEvent.FAULT, portalSearch_faultHandler, false, 0, true);
        currentPortalSearch.execute(queryParams);
    }

    protected function portalSearch_completeHandler(event:PortalSearchEvent):void
    {
        currentPortalSearch.removeEventListener(PortalSearchEvent.COMPLETE, portalSearch_completeHandler);
        currentPortalSearch.removeEventListener(FaultEvent.FAULT, portalSearch_faultHandler);

        if (event.results)
        {
            saveSearchTerm();
        }

        Model.instance.portalLayerList = new ArrayList(event.results);
        if (Model.instance.portalLayersState == 'searchloading')
        {
            Model.instance.portalLayersState = event.results.length ? 'searchresultlayers' : 'searchnomatch';
        }

        Model.instance.status = '';
    }

    protected function portalSearch_faultHandler(event:FaultEvent):void
    {
        currentPortalSearch.removeEventListener(PortalSearchEvent.COMPLETE, portalSearch_completeHandler);
        currentPortalSearch.removeEventListener(FaultEvent.FAULT, portalSearch_faultHandler);

        Model.instance.portalLayerList = new ArrayList(); //TODO: need to reset?
        if (Model.instance.portalLayersState == 'loading')
        {
            Model.instance.portalLayersState = 'searchnomatch';
        }
        Model.instance.status = '';
    }

    private function buildLayersQueryParameters(searchTerm:String):PortalQueryParameters
    {
        var queryParameters:PortalQueryParameters;
        if (user)
        {
            queryParameters = new PortalQueryParameters();
            queryParameters.addQueryCondition("(" + "(" + searchTerm + " AND " + "owner:" + user.username + ")" + " OR " + searchTerm + ")");
        }
        else
        {
            queryParameters = PortalQueryParameters.forQuery(searchTerm);
        }
        queryParameters.addQueryCondition("(" + "type:" + '"' + PortalItem.TYPE_MAP_SERVICE + '"' + " OR " + "type:" + '"' + PortalItem.TYPE_FEATURE_SERVICE + '"' + " OR " +
                                          "type:" + '"' + PortalItem.TYPE_IMAGE_SERVICE + '"' + " OR " + "type:" + '"' + PortalItem.TYPE_KML_SERVICE + '"' + ")", "AND");
        queryParameters.withLimit(100);
        return queryParameters;
    }

    private function saveSearchTerm():void
    {
        const so:SharedObject = SharedObject.getLocal(Model.USER_PREF);
        if (Model.instance.layerSearchHistory != null)
        {
            const index:int = Model.instance.layerSearchHistory.indexOf(searchTerm);
            if (index == -1)
            {
                if (Model.instance.layerSearchHistory.indexOf.length >= 50)
                {
                    Model.instance.layerSearchHistory.shift();
                }
                Model.instance.layerSearchHistory.push(searchTerm);
                var historyString:String = "";
                for (var i:int = 0; i < Model.instance.layerSearchHistory.length - 1; i++)
                {
                    historyString += Model.instance.layerSearchHistory[i] + "##";
                }
                historyString += Model.instance.layerSearchHistory[Model.instance.layerSearchHistory.length - 1];
                so.data.webMapSearchHistory = historyString;
            }
            else
            {
                Model.instance.layerSearchHistory.splice(index, 1);
                Model.instance.layerSearchHistory.push(searchTerm);
            }
        }
        else
        {
            Model.instance.layerSearchHistory = [];
            Model.instance.layerSearchHistory.push(searchTerm);
            so.data.webMapSearchHistory = searchTerm;
        }

        so.close();
    }

    private function loadBasemapsGroup():void
    {
        if (!portal.loaded)
        {
            return;
        }

        if (Model.instance.portalLayersState != 'mycontent')
        {
            Model.instance.portalLayersState = "loading";
        }

        if (currentPortalBasemapGallerySearch)
        {
            currentPortalBasemapGallerySearch.removeEventListener(PortalSearchEvent.COMPLETE, currentPortalBasemapGallerySearch_completeHandler);
            currentPortalBasemapGallerySearch.removeEventListener(FaultEvent.FAULT, currentPortalBasemapGallerySearch_faultHandler);
        }

        var queryParams:PortalQueryParameters = PortalQueryParameters.forQuery(portal.info.basemapGalleryGroupQuery);
        currentPortalBasemapGallerySearch = new PortalBasemapGallerySearch(portal);
        currentPortalBasemapGallerySearch.addEventListener(PortalSearchEvent.COMPLETE, currentPortalBasemapGallerySearch_completeHandler, false, 0, true);
        currentPortalBasemapGallerySearch.addEventListener(FaultEvent.FAULT, currentPortalBasemapGallerySearch_faultHandler, false, 0, true);
        currentPortalBasemapGallerySearch.execute(queryParams);
    }

    private function currentPortalBasemapGallerySearch_completeHandler(event:PortalSearchEvent):void
    {
        currentPortalBasemapGallerySearch.removeEventListener(PortalSearchEvent.COMPLETE, currentPortalBasemapGallerySearch_completeHandler);
        currentPortalBasemapGallerySearch.removeEventListener(FaultEvent.FAULT, currentPortalBasemapGallerySearch_faultHandler);

        const portalSearchResults:Array = event.results;
        Model.instance.basemapList = new ArrayList(portalSearchResults);
        if (Model.instance.portalLayersState == 'loading')
        {
            Model.instance.portalLayersState = portalSearchResults.length ? 'featuredlayers' : 'nomatch';
        }
    }

    protected function currentPortalBasemapGallerySearch_faultHandler(event:FaultEvent):void
    {
        currentPortalBasemapGallerySearch.removeEventListener(PortalSearchEvent.COMPLETE, currentPortalBasemapGallerySearch_completeHandler);
        currentPortalBasemapGallerySearch.removeEventListener(FaultEvent.FAULT, currentPortalBasemapGallerySearch_faultHandler);

        Model.instance.basemapList = new ArrayList();
        if (Model.instance.portalLayersState == 'loading')
        {
            Model.instance.portalLayersState = 'nomatch';
        }
    }
}
}
