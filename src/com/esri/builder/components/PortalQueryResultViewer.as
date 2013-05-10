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

import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.portal.supportClasses.PortalQueryResult;

import flash.events.Event;

import mx.collections.ArrayCollection;

import spark.components.List;
import spark.components.supportClasses.SkinnableComponent;
import spark.layouts.VerticalLayout;
import spark.layouts.supportClasses.LayoutBase;

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
[SkinState("oneResultsPage")]

/**
 *
 */
[SkinState("ready")]

//--------------------------------------
//  Events
//--------------------------------------

[Event(name="newQuery", type="com.esri.builder.components.PortalQueryResultEvent")]

[Event(name="itemSelected", type="com.esri.builder.components.PortalQueryResultItemEvent")]

/**
 *
 */
public class PortalQueryResultViewer extends SkinnableComponent
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor
     */
    public function PortalQueryResultViewer()
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
    private var m_queryResultChanged:Boolean = false;

    [Bindable("queryResultChange")]

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
            m_queryResultChanged = true;
            m_selectedItem = null;
            invalidateProperties();
            invalidateSkinState();
            dispatchEvent(new Event("queryResultChange"));
        }
    }

    //----------------------------------
    //  selectedItem
    //---------------------------------- 

    private var m_selectedItem:PortalItem;
    private var m_selectedItemId:String;
    private var m_selectedItemIdChanged:Boolean = false;

    [Bindable]
    [Bindable("queryResultChange")]

    public function get selectedItem():PortalItem
    {
        return m_selectedItem;
    }

    public function set selectedItem(value:PortalItem):void
    {
        if (value != m_selectedItem)
        {
            m_selectedItem = value;
            if (m_selectedItem && m_selectedItem.id != m_selectedItemId)
            {
                m_selectedItemId = m_selectedItem ? m_selectedItem.id : null;
                m_selectedItemIdChanged = true;
                invalidateProperties();
            }
        }
    }

    private function setSelectedItemById(itemId:String):void
    {
        var internalItem:PortalItem = null;
        if (itemId)
        {
            for each (var item:PortalItem in resultsList.dataProvider)
            {
                if (itemId == item.id)
                {
                    internalItem = item;
                    break;
                }
            }
        }
        if (resultsList)
        {
            resultsList.selectedItem = internalItem;
        }
    }

    //----------------------------------
    //  resultsListLayout
    //----------------------------------

    private var m_resultsListLayout:LayoutBase = new VerticalLayout();
    private var m_overrideLayout:Boolean = false;

    public function get resultsListLayout():LayoutBase
    {
        return (resultsList)
            ? resultsList.layout
            : m_resultsListLayout;
    }

    public function set resultsListLayout(value:LayoutBase):void
    {
        if (resultsList)
        {
            resultsList.layout = value;
        }
        m_resultsListLayout = value;
        m_overrideLayout = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  pager
    //---------------------------------- 

    [SkinPart(required="false")]

    /**
     * The pager to navigate through the results
     */
    public var pager:PortalQueryResultPager;

    //----------------------------------
    //  resultList
    //---------------------------------- 

    [SkinPart(required="true")]

    /**
     * List to display the results
     */
    public var resultsList:List;

    //--------------------------------------------------------------------------
    //
    //  Overridden Methods : Invalidation
    //
    //--------------------------------------------------------------------------

    override protected function commitProperties():void
    {
        super.commitProperties();
        if (m_queryResultChanged)
        {
            m_queryResultChanged = false;
            if (resultsList)
            {
                if (m_queryResult)
                {
                    resultsList.dataProvider = new ArrayCollection(m_queryResult.results);
                }
                else
                {
                    resultsList.dataProvider = null;
                }
                setSelectedItemById(m_selectedItemId);
            }
            if (pager)
            {
                pager.queryResult = m_queryResult;
            }
            enabled = true;
        }
        if (m_selectedItemIdChanged)
        {
            if (resultsList)
            {
                setSelectedItemById(m_selectedItemId);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods : Skin management
    //
    //--------------------------------------------------------------------------

    override protected function getCurrentSkinState():String
    {
        var state:String = "normal";
        if (m_queryResult)
        {
            var pageSize:int = m_queryResult.queryParameters.limit;
            var selectedPage:int = Math.ceil(m_queryResult.queryParameters.startIndex / pageSize);
            var numPages:int = Math.ceil(m_queryResult.totalResults / pageSize);

            if (m_queryResult.results.length == 0)
            {
                state = "noResult";
            }
            else if (numPages == 1)
            {
                state = "oneResultsPage";
            }
            else
            {
                state = "ready";
            }
        }
        return state;
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance === pager)
        {
            pager.addEventListener(PortalQueryResultEvent.NEW_QUERY, handleNewQueryEvent);
            if (m_queryResult)
            {
                pager.queryResult = m_queryResult;
            }
        }
        else if (instance === resultsList)
        {
            if (m_queryResult)
            {
                resultsList.dataProvider = new ArrayCollection(m_queryResult.results);
            }
            setSelectedItemById(m_selectedItemId);
            if (m_overrideLayout || !resultsList.layout)
            {
                m_overrideLayout = true;
                resultsList.layout = m_resultsListLayout;
            }
            resultsList.addEventListener(PortalQueryResultItemEvent.ITEM_SELECTED, resultsList_itemSelectedHandler);
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        if (instance === pager)
        {
            pager.removeEventListener(PortalQueryResultEvent.NEW_QUERY, handleNewQueryEvent);
            pager.queryResult = null
        }
        else if (instance === resultsList)
        {
            resultsList.removeEventListener(PortalQueryResultItemEvent.ITEM_SELECTED, resultsList_itemSelectedHandler);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------

    private function resultsList_itemSelectedHandler(event:PortalQueryResultItemEvent):void
    {
        if (!dispatchEvent(event))
        {
            event.preventDefault();
        }
    }

    private function handleNewQueryEvent(event:Event):void
    {
        event.stopImmediatePropagation();
        if (!dispatchEvent(event))
        {
            enabled = false;
        }
    }
}
}
