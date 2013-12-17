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
package modules.supportClasses
{

import com.esri.builder.model.ConfigLayer;

import mx.collections.ArrayList;
import mx.collections.IList;

import spark.components.List;

[Exclude(kind="property", name="dataProvider")]
[Event(name="layerIncluded", type="modules.supportClasses.ExcludeLayerListEvent")]
[Event(name="layerExcluded", type="modules.supportClasses.ExcludeLayerListEvent")]

public class ExcludeLayerList extends List
{
    private var internalDataProvider:ArrayList = new ArrayList();

    public function ExcludeLayerList()
    {
        dataProvider = internalDataProvider;
    }

    private var layerListItemsChanged:Boolean;

    public function set layerListItems(value:Array):void
    {
        if (value != internalDataProvider.source)
        {
            internalDataProvider.source = value;
            layerListItemsChanged = true;
            invalidateProperties();
        }
    }

    private var _excludedLayerNames:IList;
    private var excludedLayerNamesChanged:Boolean;

    [Bindable]
    public function get excludedLayerNames():IList
    {
        return _excludedLayerNames;
    }

    public function set excludedLayerNames(value:IList):void
    {
        _excludedLayerNames = value;
        if (excludedLayerNames)
        {
            excludedLayerNamesChanged = true;
            invalidateProperties();
        }
    }

    override protected function commitProperties():void
    {
        if (excludedLayerNamesChanged || layerListItemsChanged)
        {
            selectIncludedLayers();
            excludedLayerNamesChanged = false;
            layerListItemsChanged = false;
        }

        super.commitProperties();
    }

    private function selectIncludedLayers():void
    {
        var availableLayerListItems:Array = dataProvider.toArray();
        var availableExcludedLayerNames:Array = excludedLayerNames.toArray();
        var optionInclusion:Boolean;

        for each (var layerListItem:ExcludeLayerListItem in availableLayerListItems)
        {
            optionInclusion = true;
            for each (var layerName:String in availableExcludedLayerNames)
            {
                if (layerName == layerListItem.name)
                {
                    optionInclusion = false;
                    break;
                }
            }
            layerListItem.isIncluded = optionInclusion;
        }
    }

    public static function configLayersToLayerListItems(configLayers:Array):Array
    {
        var layerListItems:Array = [];

        for each (var configLayer:ConfigLayer in configLayers)
        {
            layerListItems.push(configLayerToLayerListItem(configLayer));
        }

        return layerListItems;
    }

    public static function configLayerToLayerListItem(configLayer:ConfigLayer):ExcludeLayerListItem
    {
        var layerListItem:ExcludeLayerListItem = new ExcludeLayerListItem();
        layerListItem.name = configLayer.label;

        return layerListItem;
    }
}
}
