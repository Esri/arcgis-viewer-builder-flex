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

import com.esri.builder.model.ConfigLayer;
import com.esri.builder.model.ConfigLayerStore;

import flash.events.Event;
import flash.utils.Dictionary;

import mx.collections.ArrayList;
import mx.collections.IList;

public class BasemapConfigLayerStore extends ConfigLayerStore
{
    private var _configLayerList:ArrayList = new ArrayList();

    [Bindable("layersChanged")]
    override public function get configLayerList():IList
    {
        _configLayerList.source = getAllUniqueLayers();
        return _configLayerList;
    }

    private function getAllUniqueLayers():Array
    {
        const uniqueLayers:Array = [];
        const processedLayerLabels:Dictionary = new Dictionary();

        for each (var configLayer:ConfigLayer in layers)
        {
            if (!processedLayerLabels[configLayer.label])
            {
                processedLayerLabels[configLayer.label] = true;
                uniqueLayers.push(configLayer);
            }
        }

        return uniqueLayers;
    }

    //TODO: optimize
    override public function moveLayerUp(layer:ConfigLayer):void
    {
        const bottomGroupedLayers:Array = getGroupedLayersByLabel(layer.label);
        for each (var bottomLayerToRemove:ConfigLayer in bottomGroupedLayers.slice(1))
        {
            removeLayerInternally(bottomLayerToRemove);
        }

        const topLayerIndex:int = layers.indexOf(layer) - 1;
        const canMoveLayerUp:Boolean = topLayerIndex > -1;
        if (!canMoveLayerUp)
        {
            insertLayersAfter(layer, bottomGroupedLayers.slice(1));
            return;
        }

        const topLayerLabel:String = layers[topLayerIndex].label;
        const topGroupedLayers:Array = getGroupedLayersByLabel(topLayerLabel);
        for each (var topLayerToRemove:ConfigLayer in topGroupedLayers.slice(1))
        {
            removeLayerInternally(topLayerToRemove);
        }

        moveLayerUpInternally(layer);

        insertLayersAfter(layer, bottomGroupedLayers.slice(1));
        const topLayer:ConfigLayer = topGroupedLayers[0];
        insertLayersAfter(topLayer, topGroupedLayers.slice(1));

        dispatchEvent(new Event("layersChanged"));
    }

    private function getGroupedLayersByLabel(layerName:String):Array
    {
        const groupedLayers:Array = [];

        for each (var configLayer:ConfigLayer in layers)
        {
            if (configLayer.label == layerName)
            {
                groupedLayers.push(configLayer);
            }
        }

        return groupedLayers;
    }

    private function insertLayersAfter(layer:ConfigLayer, layersToInsert:Array):void
    {
        const insertionIndex:int = layers.indexOf(layer) + 1;

        for each (var layerToInsert:ConfigLayer in layersToInsert)
        {
            layers.splice(insertionIndex++, 0, layerToInsert);
        }
    }

    //TODO: optimize
    override public function moveLayerDown(layer:ConfigLayer):void
    {
        const topGroupedLayers:Array = getGroupedLayersByLabel(layer.label);
        for each (var topLayerToRemove:ConfigLayer in topGroupedLayers.slice(1))
        {
            removeLayerInternally(topLayerToRemove);
        }

        const bottomLayerIndex:int = layers.indexOf(layer) + 1;
        const canMoveLayerDown:Boolean = bottomLayerIndex < layers.length;
        if (!canMoveLayerDown)
        {
            insertLayersAfter(layer, topGroupedLayers.slice(1));
            return;
        }

        const bottomLayerLabel:String = layers[bottomLayerIndex].label;
        const bottomGroupedLayers:Array = getGroupedLayersByLabel(bottomLayerLabel);
        for each (var bottomLayerToRemove:ConfigLayer in bottomGroupedLayers.slice(1))
        {
            removeLayerInternally(bottomLayerToRemove);
        }

        moveLayerDownInternally(layer);

        insertLayersAfter(layer, topGroupedLayers.slice(1));
        const bottomLayer:ConfigLayer = bottomGroupedLayers[0];
        insertLayersAfter(bottomLayer, bottomGroupedLayers.slice(1));

        dispatchEvent(new Event("layersChanged"));
    }

    override public function removeLayer(layer:ConfigLayer):void
    {
        const configLayersToRemove:Array = getGroupedLayersByLabel(layer.label);

        for each (var configLayerToRemove:ConfigLayer in configLayersToRemove)
        {
            removeLayerInternally(configLayerToRemove);
        }

        dispatchEvent(new Event("layersChanged"));
    }

    public function syncLayers(layer:ConfigLayer, previousLayerName:String = null):void
    {
        const updatedLayerName:String = previousLayerName ? previousLayerName : layer.label;
        const groupedLayers:Array = getGroupedLayersByLabel(updatedLayerName);

        for each (var groupedLayer:ConfigLayer in groupedLayers)
        {
            groupedLayer.label = layer.label;
            groupedLayer.visible = layer.visible;
        }

        dispatchEvent(new Event("layersChanged"));
    }
}
}
