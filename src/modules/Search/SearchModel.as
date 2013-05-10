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
package modules.Search
{

import modules.IWidgetModel;

import mx.collections.ArrayList;

public class SearchModel implements IWidgetModel
{
    [Bindable]
    public var searchLayers:ArrayList = new ArrayList();
    [Bindable]
    public var zoomScale:String = "50000";
    [Bindable]
    public var shareResults:Boolean = false;

    public function importXML(doc:XML):void
    {
        zoomScale = doc.zoomscale;
        shareResults = doc.shareresults[0] == "true";
        importSearchLayersXML(doc.layers.layer)
    }

    private function importSearchLayersXML(searchLayersXMLList:XMLList):void
    {
        var searchLayer:SearchLayer;
        for each (var searchLayerXML:XML in searchLayersXMLList)
        {
            searchLayer = new SearchLayer();
            searchLayer.fromXML(searchLayerXML);
            searchLayers.addItem(searchLayer);
        }
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <zoomscale>{zoomScale}</zoomscale>
                <shareresults>{shareResults}</shareresults>
            </configuration>
        if (searchLayers.length)
        {
            configXML.appendChild(exportSearchLayersXML());
        }
        return configXML;
    }

    private function exportSearchLayersXML():XML
    {
        var searchLayersXML:XML = <layers/>;
        var searchLayersSource:Array = searchLayers.source;
        for each (var searchLayer:SearchLayer in searchLayersSource)
        {
            searchLayersXML.appendChild(searchLayer.toXML());
        }
        return searchLayersXML;
    }
}
}
