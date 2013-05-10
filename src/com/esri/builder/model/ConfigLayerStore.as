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

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayList;
import mx.collections.IList;

public class ConfigLayerStore extends EventDispatcher
{
    protected var layers:Array = [];

    public function addLayer(layer:ConfigLayer):void
    {
        if (layer)
        {
            layers.push(layer);
            dispatchEvent(new Event('layersChanged'));
        }
    }

    public function importLayers(layers:Array):void
    {
        if (layers)
        {
            this.layers = layers;
            dispatchEvent(new Event("layersChanged"));
        }
    }

    public function getAllLayers():Array
    {
        return layers.concat();
    }

    public function getLayerAt(index:int):ConfigLayer
    {
        var configLayer:ConfigLayer;

        if (index > -1
            && index <= layers.length)
        {
            configLayer = layers[index];
        }

        return configLayer;
    }

    public function moveLayerUp(layer:ConfigLayer):void
    {
        //reverse direction since presentation model is reversed
        moveLayerDownInternally(layer);
        dispatchEvent(new Event("layersChanged"));
    }

    protected function moveLayerDownInternally(layer:ConfigLayer):void
    {
        const destinationIndex:int = layers.indexOf(layer) + 1;
        if (destinationIndex < layers.length)
        {
            const previousLayer:ConfigLayer = layers[destinationIndex];
            layers.splice(destinationIndex - 1, 2, previousLayer, layer);
        }
    }

    public function moveLayerDown(layer:ConfigLayer):void
    {
        //reverse direction since presentation model is reversed
        moveLayerUpInternally(layer);
        dispatchEvent(new Event("layersChanged"));
    }

    protected function moveLayerUpInternally(layer:ConfigLayer):void
    {
        const destinationIndex:int = layers.indexOf(layer) - 1;
        if (destinationIndex > -1)
        {
            const previousLayer:ConfigLayer = layers[destinationIndex];
            layers.splice(destinationIndex, 2, layer, previousLayer);
        }
    }

    public function removeLayer(layer:ConfigLayer):void
    {
        removeLayerInternally(layer);
        dispatchEvent(new Event("layersChanged"));
    }

    protected function removeLayerInternally(layer:ConfigLayer):void
    {
        var deletionIndex:int = layers.indexOf(layer);
        if (deletionIndex > -1)
        {
            layers.splice(deletionIndex, 1);
        }
    }

    public function removeAllLayers():void
    {
        layers.splice(0, layers.length);
        dispatchEvent(new Event("layersChanged"));
    }

    [Bindable("layersChanged")]
    public function get hasLayers():Boolean
    {
        return layers && layers.length > 0;
    }

    private var _configLayerList:ArrayList = new ArrayList();

    [Bindable("layersChanged")]
    public function get configLayerList():IList
    {
        _configLayerList.source = getAllLayers().reverse();
        return _configLayerList;
    }

    public function isConfigLayerLabelUnique(label:String):Boolean
    {
        var isLabelUnique:Boolean = true;

        for each (var layer:ConfigLayer in layers)
        {
            if (layer.label == label)
            {
                isLabelUnique = false;
                break;
            }
        }

        return isLabelUnique;
    }

    public function toXML():XMLList
    {
        var layersXML:XMLList = new XMLList();

        for each (var configLayer:ConfigLayer in layers)
        {
            layersXML += configLayer.encodeXML();
        }

        return layersXML;
    }
}
}
