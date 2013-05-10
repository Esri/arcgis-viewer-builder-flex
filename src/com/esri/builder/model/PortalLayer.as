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
package com.esri.builder.model
{

import com.esri.ags.portal.supportClasses.PortalItem;

public class PortalLayer
{
    public var serviceURL:String;
    public var serviceURL2:String;
    /**
     * TODO: need to redesign Basemap model
     * The layer type (present for non-Esri layers)
     */
    public var type:String;

    private var portalItem:PortalItem;

    public function PortalLayer(portalItem:PortalItem)
    {
        this.portalItem = portalItem;
    }

    public function get id():String
    {
        return portalItem.id;
    }

    public function get isPublic():Boolean
    {
        return (portalItem.access == "public");
    }

    public function get thumbnailURL():String
    {
        return portalItem.thumbnailURL;
    }

    public function get title():String
    {
        return portalItem.title;
    }

    public function get itemType():String
    {
        return portalItem.type;
    }
}
}
