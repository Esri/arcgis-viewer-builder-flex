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

import flash.events.Event;

public class SearchInputEvent extends Event
{
    public static const SEARCH:String = "search";

    public function SearchInputEvent(searchTerm:String)
    {
        super(SEARCH, true, false);
        m_searchTerm = searchTerm;
    }
    private var m_searchTerm:String;

    public function get searchTerm():String
    {
        return m_searchTerm;
    }

    override public function clone():Event
    {
        return new SearchInputEvent(searchTerm);
    }
}
}
