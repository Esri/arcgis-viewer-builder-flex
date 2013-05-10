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
import com.esri.ags.portal.supportClasses.PortalGroup;
import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.portal.supportClasses.PortalQueryParameters;
import com.esri.ags.portal.supportClasses.PortalQueryResult;
import com.esri.ags.portal.supportClasses.PortalUser;
import com.esri.ags.tasks.supportClasses.CallResponder;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalModel;
import com.esri.builder.supportClasses.LogUtil;

import flash.net.SharedObject;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.rpc.AsyncResponder;
import mx.rpc.Fault;

public final class WebMapController
{

    //--------------------------------------------------------------------------
    //
    //  Class Constants
    //
    //--------------------------------------------------------------------------

    private static const LOG:ILogger = LogUtil.createLogger(WebMapController);

    public static const ITEMS_QUERY_LIMIT:uint = 20;

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor
     */
    public function WebMapController()
    {
        AppEvent.addListener(AppEvent.WEB_MAP_SEARCH, webMapSearchHandler, false, 0, true);
        portal = PortalModel.getInstance().portal;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     * User search
     */
    private var lastSearchType:String;
    private var lastSearchTerm:String;

    private var portal:Portal;
    private var lastUsedPortalURL:String;
    private var lastUsedCultureCode:String;

    //--------------------------------------------------------------------------
    //
    //  Application Event Handlers
    //
    //--------------------------------------------------------------------------

    /**
     * Handle the search events.
     *
     * Data Object format:
     *
     * {
     *      type:String                             // REQUIRED values: featured, search
     *      responder:CallResponder                 // REQUIRED handle the token and the last result for the search
     *      searchTerm:String                       //  - for new searches
     *      queryParameters:PortalQueryParameters   //  - for existing searches (paging, sorting...)
     * }
     *
     */
    private function webMapSearchHandler(event:AppEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info("searching web map term");
        }

        if (event.data.queryParameters)
        {
            queryWithParameters(event.data.type, event.data.queryParameters, event.data.responder);
        }
        else
        {
            queryPortal(event.data.type, event.data.searchTerm, event.data.responder);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods : Search
    //
    //--------------------------------------------------------------------------

    private function queryWithParameters(type:String, queryParameters:PortalQueryParameters, responder:CallResponder):void
    {
        lastSearchType = type;
        if (type == "featured")
        {
            Model.instance.webmapState = "loading";
            responder.token = portal.queryItems(queryParameters, new AsyncResponder(groupItems_resultHandler, portal_faultHandler, responder));
        }
        else if (type == "search")
        {
            Model.instance.webmapState = 'searchloading';
            responder.token = portal.queryItems(queryParameters, new AsyncResponder(portal_searchResultHandler, portal_faultHandler, responder));
        }
    }

    private function queryPortal(type:String, searchTerm:String, responder:CallResponder):void
    {
        lastSearchType = type;
        lastSearchTerm = searchTerm ? searchTerm : "";
        lastUsedPortalURL = PortalModel.getInstance().portalURL;
        lastUsedCultureCode = Model.instance.cultureCode;

        Model.instance.webmapAddEnabled = false;
        var user:PortalUser;
        if (type == "featured" || (type == "search" && !portal.signedIn && lastSearchTerm == ""))
        {
            getFeaturedContent(responder);
        }
        else if (type == "search")
        {
            var queryParameters:PortalQueryParameters;
            if (lastSearchTerm != "")
            {
                if (isWebMapID(lastSearchTerm))
                {
                    queryParameters = PortalQueryParameters.forItemWithId(lastSearchTerm);
                }
                else
                {
                    if (portal.signedIn)
                    {
                        user = portal.user;
                        queryParameters = PortalQueryParameters.forQuery("(" + "((" + lastSearchTerm + ") AND " + "owner:" + user.username + ")" + " OR (" + lastSearchTerm + "))");
                    }
                    else
                    {
                        queryParameters = PortalQueryParameters.forQuery(lastSearchTerm);
                    }
                }
            }
            else if (portal.signedIn)
            {
                user = portal.user;
                queryParameters = new PortalQueryParameters();
                queryParameters.addQueryCondition("owner:" + user.username);
            }

            queryParameters.ofType(PortalItem.TYPE_WEB_MAP);
            queryParameters.withLimit(ITEMS_QUERY_LIMIT);

            Model.instance.webmapState = 'searchloading';
            responder.token = portal.queryItems(queryParameters, new AsyncResponder(portal_searchResultHandler, portal_faultHandler, responder));
        }
    }

    private function isWebMapID(searchTerm:String):Boolean
    {
        var webMapID:RegExp = /^[a-zA-Z0-9]{32}$/;
        return webMapID.test(searchTerm);
    }

    private function portal_searchResultHandler(queryResult:PortalQueryResult, responder:CallResponder):void
    {
        const numResults:uint = queryResult.results.length;
        if (numResults > 0)
        {
            saveSearchTerm();
        }
        if (Model.instance.webmapState == 'searchloading')
        {
            Model.instance.webmapState = numResults ? 'searchresultmaps' : 'searchnomatch';
        }
        Model.instance.status = '';
    }

    private function saveSearchTerm():void
    {
        const so:SharedObject = SharedObject.getLocal(Model.USER_PREF);
        if (Model.instance.webMapSearchHistory != null)
        {
            const index:int = Model.instance.webMapSearchHistory.indexOf(lastSearchTerm);
            if (index == -1)
            {
                if (Model.instance.webMapSearchHistory.indexOf.length >= 50)
                {
                    Model.instance.webMapSearchHistory.shift();
                }
                Model.instance.webMapSearchHistory.push(lastSearchTerm);
                var historyString:String = "";
                for (var i:int = 0; i < Model.instance.webMapSearchHistory.length - 1; i++)
                {
                    historyString += Model.instance.webMapSearchHistory[i] + "##";
                }
                historyString += Model.instance.webMapSearchHistory[Model.instance.webMapSearchHistory.length - 1];
                so.data.webMapSearchHistory = historyString;
            }
            else
            {
                Model.instance.webMapSearchHistory.splice(index, 1);
                Model.instance.webMapSearchHistory.push(lastSearchTerm);
            }
        }
        else
        {
            Model.instance.webMapSearchHistory = new Array();
            Model.instance.webMapSearchHistory.push(lastSearchTerm);
            so.data.webMapSearchHistory = lastSearchTerm;
        }

        so.close();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods : Featured content
    //
    //--------------------------------------------------------------------------

    private function getFeaturedContent(responder:CallResponder):void
    {
        if (Log.isInfo())
        {
            LOG.info("getting featured content");
        }

        if (Model.instance.webmapState != 'mycontent')
        {
            Model.instance.webmapState = "loading";
        }

        var queryParams:PortalQueryParameters;

        if (portal.info.featuredItemsGroupQuery != "")
        {
            queryParams = PortalQueryParameters.forQuery(portal.info.featuredItemsGroupQuery);
            portal.queryGroups(queryParams, new AsyncResponder(featuredGroups_resultHandler, portal_faultHandler, responder));
        }
        else
        {
            queryParams = new PortalQueryParameters()
            queryParams.ofType(PortalItem.TYPE_WEB_MAP);
            if (portal.info.organizationId)
            {
                queryParams.addQueryCondition("(orgid:" + portal.info.organizationId + ")", "AND");
            }
            queryParams.withSortField("numviews").withSortOrder("desc").withLimit(ITEMS_QUERY_LIMIT);
            responder.token = portal.queryItems(queryParams, new AsyncResponder(groupItems_resultHandler, portal_faultHandler, responder));
        }
    }

    protected function featuredGroups_resultHandler(queryResult:PortalQueryResult, responder:CallResponder):void
    {
        if (queryResult.results.length > 0)
        {
            var portalGroup:PortalGroup = queryResult.results[0] as PortalGroup;
            var queryParams:PortalQueryParameters = new PortalQueryParameters();
            queryParams.ofType(PortalItem.TYPE_WEB_MAP).withSortField("name").withLimit(ITEMS_QUERY_LIMIT);
            responder.token = portalGroup.queryItems(queryParams, new AsyncResponder(groupItems_resultHandler, portal_faultHandler, responder));
        }
    }

    private function groupItems_resultHandler(queryResult:PortalQueryResult, responder:CallResponder):void
    {
        if (Log.isInfo())
        {
            LOG.info("featured groups result");
        }

        // TODO remove webmapQuery & mapsView.esriFeaturedContent
        //Model.instance.webmapQuery = ResourceManager.getInstance().getString('BuilderStrings', 'mapsView.esriFeaturedContent');
        var state:String = Model.instance.webmapState;
        if (state == 'loading')
        {
            const numResults:uint = queryResult.results.length;
            Model.instance.webmapState = numResults ? 'featuredmaps' : 'nomatch';
        }
        Model.instance.status = '';
    }

    //--------------------------------------------------------------------------
    //
    //  Fault Handler
    //
    //--------------------------------------------------------------------------

    private function portal_faultHandler(fault:Fault, responder:CallResponder):void
    {
        if (Log.isDebug())
        {
            LOG.debug("portal query fault {0}", fault.toString());
        }

        responder.lastResult = null;

        if (lastSearchTerm && Model.instance.webmapState == 'searchloading')
        {
            Model.instance.webmapState = 'searchnomatch';
        }
        else if (Model.instance.webmapState == 'loading')
        {
            Model.instance.webmapState = 'nomatch';
        }
    }
}
}
