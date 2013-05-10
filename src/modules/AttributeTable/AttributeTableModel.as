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
package modules.AttributeTable
{

import com.esri.builder.model.Model;
import com.esri.builder.model.WidgetContainer;

import modules.IWidgetModel;
import modules.supportClasses.LayerSettings;

import mx.collections.ArrayList;

public final class AttributeTableModel implements IWidgetModel
{
    [Bindable]
    public var isOpenOnStartUp:Boolean = true;
    [Bindable]
    public var excludedLayers:ArrayList;
    public var layerSettings:Array = [];

    public function AttributeTableModel()
    {
        excludedLayers = new ArrayList();
        for each (var widgetContainer:WidgetContainer in Model.instance.config.widgetContainerArray)
        {
            if (widgetContainer.panelType == "bottom")
            {
                isOpenOnStartUp = widgetContainer.initialState == "open" ? true : false;
                break;
            }
        }
    }

    public function importXML(doc:XML):void
    {
        var excludedLayersXML:XMLList = doc.excludelayer;
        for each (var excludedLayerNameXML:XML in excludedLayersXML)
        {
            excludedLayers.addItem(excludedLayerNameXML.toString());
        }

        var parsedLayerSettings:LayerSettings;
        for each (var settings:XML in doc.layersettings.layer)
        {
            parsedLayerSettings = new LayerSettings();
            parsedLayerSettings.fromXML(settings);
            if (parsedLayerSettings.name)
            {
                layerSettings.push(parsedLayerSettings);
            }
        }
    }

    public function exportXML():XML
    {
        var configXML:XML = <configuration>
            </configuration>;

        appendExcludedLayers(configXML);
        appendLayerSettings(configXML);

        return configXML;
    }

    private function appendLayerSettings(configXML:XML):void
    {
        if (layerSettings.length > 0)
        {
            var layerSettingsXML:XML = <layersettings/>;

            for each (var layerSetting:LayerSettings in layerSettings)
            {
                layerSettingsXML.appendChild(layerSetting.toXML());
            }

            if (layerSettingsXML.children().length() > 0)
            {
                configXML.appendChild(layerSettingsXML);
            }
        }
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

    public function findLayerSettings(layerName:String):LayerSettings
    {
        var matchingLayerSettings:LayerSettings;

        for each (var layerSettingsItem:LayerSettings in layerSettings)
        {
            if (layerSettingsItem.name == layerName)
            {
                matchingLayerSettings = layerSettingsItem;
                break;
            }
        }

        return matchingLayerSettings;
    }
}

}
