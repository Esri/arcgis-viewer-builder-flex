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
package modules.HeaderController
{

import mx.collections.ArrayList;

[Bindable]
public class MapService
{
    public var url:String;
    public var layerIds:ArrayList = new ArrayList();
    public var searchFields:ArrayList = new ArrayList();
    public var name:String;
    public var proxyURL:String;
    public var useProxy:Boolean;

    public function toXML():XML
    {
        var mapServiceXML:XML = <mapservice/>;

        if (url)
        {
            mapServiceXML.appendChild(<url>{url}</url>);
        }
        if (layerIds.length > 0)
        {
            mapServiceXML.appendChild(<layerids>{layerIds.source.join()}</layerids>);
        }
        if (searchFields.length > 0)
        {
            mapServiceXML.appendChild(<searchfields>{searchFields.source.join()}</searchfields>);
        }
        if (name)
        {
            mapServiceXML.appendChild(<name>{name}</name>);
        }
        if (proxyURL)
        {
            mapServiceXML.appendChild(<proxyurl>{proxyURL}</proxyurl>);
        }
        if (useProxy)
        {
            mapServiceXML.appendChild(<useproxy>{searchFields.source.join()}</useproxy>);
        }

        return mapServiceXML;
    }
}
}
