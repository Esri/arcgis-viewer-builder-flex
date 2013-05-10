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
package com.esri.builder.components
{

import com.esri.ags.portal.supportClasses.PortalQueryParameters;
import com.esri.ags.portal.supportClasses.PortalQueryResult;
import com.esri.builder.components.PortalQueryResultEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayList;
import mx.collections.IList;

import spark.components.Button;
import spark.components.DataGroup;
import spark.components.supportClasses.ListBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.IndexChangeEvent;
import spark.events.RendererExistenceEvent;

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *
 */
[SkinState("normal")]

/**
 *
 */
[SkinState("noResult")]

/**
 *
 */
[SkinState("ready")]

//--------------------------------------
//  Events
//--------------------------------------

[Event(name="newQuery", type="com.esri.builder.components.PortalQueryResultEvent")]

/**
 * Simple component to help paging results from a query against the portal
 */
public class PortalQueryResultPager extends SkinnableComponent
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor
     */
    public function PortalQueryResultPager()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  previousLabel
    //---------------------------------- 

    [Bindable]

    public var previousLabel:String = "Previous";

    //----------------------------------
    //  nextLabel
    //----------------------------------

    [Bindable]

    public var nextLabel:String = "Next";

    //----------------------------------
    //  queryResult
    //---------------------------------- 

    private var m_queryResult:PortalQueryResult;

    [Bindable]

    /**
     * The result from the query.
     */
    public function get queryResult():PortalQueryResult
    {
        return m_queryResult;
    }

    /**
     * @private
     */
    public function set queryResult(value:PortalQueryResult):void
    {
        if (m_queryResult != value)
        {
            m_queryResult = value;
            if (m_queryResult)
            {
                queryParameters = m_queryResult.queryParameters;
            }
            else
            {
                queryParameters = null;
            }
        }
    }

    //----------------------------------
    //  queryParameters
    //---------------------------------- 

    private var m_queryParameters:PortalQueryParameters;

    private var m_queryParametersChanged:Boolean = false;

    private function set queryParameters(value:PortalQueryParameters):void
    {
        if (m_queryParameters != value)
        {
            m_queryParameters = value;
            m_queryParametersChanged = true;
            invalidateProperties();
            invalidateSkinState();
        }
    }

    //----------------------------------
    //  selectedIndex
    //---------------------------------- 

    private var m_selectedIndex:int;

    [Bindable("queryParametersChange")]

    /**
     * @private
     * The selected item of the page list.
     */
    public function get selectedIndex():int
    {
        return m_selectedIndex;
    }

    //----------------------------------
    //  pages
    //---------------------------------- 

    private var m_pages:IList = new ArrayList;

    [Bindable("queryParametersChange")]

    /**
     * @private
     * The list of items to display in the list.
     */
    public function get pages():IList
    {
        return m_pages;
    }

    //----------------------------------
    //  hasPrevious
    //---------------------------------- 

    [Bindable("queryParametersChange")]

    /**
     * @private
     * Flag that is <code>true</code> if previous results can be queried.
     */
    public function get hasPrevious():Boolean
    {
        return m_queryResult && m_queryResult.hasPrevious;
    }

    //----------------------------------
    //  hasNext
    //---------------------------------- 

    [Bindable("queryParametersChange")]

    /**
     * @private
     * Flag that is <code>true</code> if next results can be queried.
     */
    public function get hasNext():Boolean
    {
        return m_queryResult && m_queryResult.hasNext;
    }

    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  previousButton
    //---------------------------------- 

    [SkinPart(required="false")]

    /**
     * The button used to ask for the previous page.
     */
    public var previousButton:Button;

    //----------------------------------
    //  nextButton
    //---------------------------------- 

    [SkinPart(required="false")]

    /**
     * The button used to ask for the next page.
     */
    public var nextButton:Button;

    //----------------------------------
    //  pageList
    //---------------------------------- 

    [SkinPart(required="false")]

    /**
     * The list of pages.
     */
    public var pageList:ListBase;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods : Invalidation
    //
    //--------------------------------------------------------------------------

    override protected function commitProperties():void
    {
        super.commitProperties()

        if (m_queryParametersChanged)
        {
            m_queryParametersChanged = false;
            if (m_queryParameters)
            {
                setQueryParameters(m_queryParameters, m_queryResult.totalResults);
            }
            else
            {
                setQueryParameters(null);
            }
            dispatchEvent(new Event("queryParametersChange"));
        }
    }

    private function setQueryParameters(queryParameters:PortalQueryParameters, totalResults:uint = 0):void
    {
        m_pages.removeAll();

        m_selectedIndex = -1;

        if (queryParameters)
        {
            var pageSize:int = queryParameters.limit;
            var selectedPage:int = Math.ceil(queryParameters.startIndex / pageSize);
            var numPages:int = Math.ceil(totalResults / pageSize);

            if (numPages > 0)
            {
                var i:int = selectedPage - 1;
                while (i > 0 && i > selectedPage - 4)
                {
                    m_pages.addItemAt(createPageItem(i), 0);
                    i--;
                }

                m_pages.addItem(createPageItem(selectedPage));
                m_selectedIndex = m_pages.length - 1;

                i = selectedPage + 1;
                while (i <= numPages && i < selectedPage + 4)
                {
                    m_pages.addItem(createPageItem(i));
                    i++;
                }

                if (m_pages.getItemAt(0).label != "1")
                {
                    // if 2 | 3 | 4 | 5 no need of the dots
                    if (m_pages.getItemAt(0).label != "2")
                    {
                        m_pages.addItemAt({ label: "...", enabled: false }, 0);
                        m_selectedIndex++;
                    }
                    m_pages.addItemAt(createPageItem(1), 0);
                    m_selectedIndex++;
                }

                if (m_pages.getItemAt(m_pages.length - 1).label != numPages.toString())
                {
                    // if last page is 30 and pages are 27 | 28 | 29 no need of the dots
                    if (uint(m_pages.getItemAt(m_pages.length - 1).label) != numPages - 1)
                    {
                        m_pages.addItem({ label: "...", enabled: false });
                    }
                    m_pages.addItem(createPageItem(numPages));
                }
            }
        }
    }

    private function createPageItem(pageNumber:uint):Object
    {
        return { uid: pageNumber.toString(), label: pageNumber.toString(), enabled: true };
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods : Skin management
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override protected function getCurrentSkinState():String
    {
        var state:String = "normal";
        if (m_queryResult)
        {
            if (m_queryResult.results.length == 0)
            {
                state = "noResult";
            }
            else
            {
                state = "ready";
            }
        }
        return state;
    }

    /**
     * @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance === pageList)
        {
            pageList.addEventListener(IndexChangeEvent.CHANGE, indexChangeHandler);
        }
        else if (instance === previousButton)
        {
            previousButton.addEventListener(MouseEvent.CLICK, previousHandler);
        }
        else if (instance === nextButton)
        {
            nextButton.addEventListener(MouseEvent.CLICK, nextHandler);
        }
    }

    /**
     * @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        if (instance === pageList)
        {
            pageList.removeEventListener(IndexChangeEvent.CHANGE, indexChangeHandler);
        }
        else if (instance === previousButton)
        {
            previousButton.removeEventListener(MouseEvent.CLICK, previousHandler);
        }
        else if (instance === nextButton)
        {
            previousButton.removeEventListener(MouseEvent.CLICK, nextHandler);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event handler
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     * dispatch an event with the PortalQueryParameters for the selected page.
     */
    private function indexChangeHandler(event:IndexChangeEvent):void
    {
        var queryParameters:PortalQueryParameters = queryResult.queryParameters.clone();
        queryParameters.startIndex = ((uint(m_pages.getItemAt(event.newIndex).label) - 1) * queryParameters.limit) + 1;
        var evt:PortalQueryResultEvent = new PortalQueryResultEvent(PortalQueryResultEvent.NEW_QUERY, queryParameters);
        if (!dispatchEvent(evt))
        {
            event.preventDefault();
        }
        else
        {
            setQueryParameters(queryParameters, queryResult.totalResults);
        }
    }

    /**
     * @private
     * dispatch an event with the PortalQueryParameters for the next page.
     */
    private function nextHandler(event:MouseEvent):void
    {
        var evt:PortalQueryResultEvent = new PortalQueryResultEvent(PortalQueryResultEvent.NEW_QUERY, queryResult.nextQueryParameters);
        if (!dispatchEvent(evt))
        {
            setQueryParameters(queryResult.nextQueryParameters, queryResult.totalResults);
        }
    }

    /**
     * @private
     * dispatch an event with the PortalQueryParameters for the previous page.
     */
    private function previousHandler(event:MouseEvent):void
    {
        var evt:PortalQueryResultEvent = new PortalQueryResultEvent(PortalQueryResultEvent.NEW_QUERY, queryResult.previousQueryParameters);
        if (!dispatchEvent(evt))
        {
            setQueryParameters(queryResult.previousQueryParameters, queryResult.totalResults);
        }
    }

}
}
