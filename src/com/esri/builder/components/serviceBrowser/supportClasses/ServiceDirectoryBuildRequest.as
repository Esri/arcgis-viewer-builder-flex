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

public class ServiceDirectoryBuildRequest
{
    public static const MAP_LAYER_SEARCH:String = "mapLayerSearch";
    public static const GEOPROCESSING_TASK_SEARCH:String = "geoprocessingTaskSearch";
    public static const QUERYABLE_LAYER_SEARCH:String = "queryLayerSearch";
    public static const QUERYABLE_TABLE_SEARCH:String = "queryTableSearch";
    public static const GEOCODER_SEARCH:String = "geocoderSearch";
    public static const ROUTE_LAYER_SEARCH:String = "routeLayerSearch";
    public static const MAP_SERVER_SEARCH:String = "mapServerSearch";

    public var url:String;
    public var searchType:String;

    public function ServiceDirectoryBuildRequest(url:String, searchType:String)
    {
        this.url = url;
        this.searchType = searchType;
    }
}
}
