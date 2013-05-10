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

import flash.events.Event;

/**
 * The PortalQueryEvent class represents event objects dispatched by the PortalQueryResultPager class.
 */
public class PortalQueryResultEvent extends Event
{

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     * The PortalQueryEvent.NEW_QUERY constant defines the value of the type property of the event object for an new query event.
     */
    public static const NEW_QUERY:String = "newQuery";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor
     *
     * @param type The event type.
     * @param queryParameters The query parameters for the new query.
     */
    public function PortalQueryResultEvent(type:String, queryParameters:PortalQueryParameters)
    {
        super(type, true, true);
        m_queryParameters = queryParameters;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  queryParameters
    //---------------------------------- 

    private var m_queryParameters:PortalQueryParameters;

    /**
     * The query parameters for the new query.
     */
    public function get queryParameters():PortalQueryParameters
    {
        return m_queryParameters;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @private
     */
    override public function clone():Event
    {
        return new PortalQueryResultEvent(type, queryParameters);
    }

}
}
