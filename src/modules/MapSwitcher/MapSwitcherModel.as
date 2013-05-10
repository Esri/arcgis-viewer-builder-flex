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
package modules.MapSwitcher
{

import modules.IWidgetModel;

import mx.resources.ResourceManager;

public final class MapSwitcherModel implements IWidgetModel
{
    [Bindable]
    public var moreLabel:String = ResourceManager.getInstance().getString('BuilderStrings', 'mapSwitcher.more');
    [Bindable]
    public var basemapsLabel:String = ResourceManager.getInstance().getString('BuilderStrings', 'mapSwitcher.basemap');
    [Bindable]
    public var layerListVisible:Boolean = true;
    [Bindable]
    public var showThumbnails:Boolean = true;
    [Bindable]
    public var expandLayerItems:Boolean = false;
    [Bindable]
    public var includeLegendItems:Boolean = true;

    //TODO: implement excludelayers
    public function importXML(doc:XML):void
    {
        if (doc.labels.layerlistlabel[0])
        {
            moreLabel = doc.labels.layerlistlabel;
        }
        if (doc.labels.basemapslabel[0])
        {
            basemapsLabel = doc.labels.basemapslabel;
        }

        layerListVisible = (doc.layerlist.@visible[0] == "true");
        showThumbnails = (doc.showthumbnails[0] != "false");
        expandLayerItems = (doc.expandlayeritems[0] == "true");
        includeLegendItems = (doc.includelegenditems[0] != "false");
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <layerlist/>
                <labels>
                    <layerlistlabel>{moreLabel}</layerlistlabel>
                    <basemapslabel>{basemapsLabel}</basemapslabel>
                </labels>
                <showthumbnails>{showThumbnails}</showthumbnails>
                <includelegenditems>{includeLegendItems}</includelegenditems>
            </configuration>;

        if (expandLayerItems)
        {
            configXML.appendChild(<expandlayeritems>{expandLayerItems}</expandlayeritems>);
        }

        configXML.layerlist.@visible = layerListVisible;

        return configXML;
    }
}
}
