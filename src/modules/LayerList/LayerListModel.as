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
package modules.LayerList
{

import modules.IWidgetModel;

import mx.collections.ArrayList;

public final class LayerListModel implements IWidgetModel
{
    [Bindable]
    public var excludedLayers:ArrayList;
    [Bindable]
    public var expandLayerItems:Boolean = false;
    [Bindable]
    public var includeLegendItems:Boolean = true;

    public function LayerListModel()
    {
        excludedLayers = new ArrayList();
    }

    public function importXML(doc:XML):void
    {
        var excludedLayersXML:XMLList = doc.excludelayer;
        for each (var excludedLayerNameXML:XML in excludedLayersXML)
        {
            excludedLayers.addItem(excludedLayerNameXML.toString());
        }
        expandLayerItems = (doc.expandlayeritems[0] == "true");
        includeLegendItems = (doc.includelegenditems[0] != "false");
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <includelegenditems>{includeLegendItems}</includelegenditems>
            </configuration>;
        appendExcludedLayers(configXML);
        if (expandLayerItems)
        {
            configXML.appendChild(<expandlayeritems>{expandLayerItems}</expandlayeritems>);
        }
        return configXML;
    }

    private function appendExcludedLayers(configXML:XML):void
    {
        var excludedLayersSource:Array = excludedLayers.source;
        var excludeLayerXML:XML;
        for each (var layerName:String in excludedLayersSource)
        {
            excludeLayerXML = <excludelayer>{layerName}</excludelayer>
            configXML.appendChild(excludeLayerXML);
        }
    }
}
}
