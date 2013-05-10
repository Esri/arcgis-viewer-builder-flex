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
package com.esri.builder.views
{

import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.Layer;
import com.esri.ags.layers.supportClasses.LayerInfo;

import mx.collections.ArrayList;

import spark.components.List;

[Exclude(kind="property", name="dataProvider")]
public class SubLayerList extends List
{
    private var _layer:Layer;

    public function get layer():Layer
    {
        return _layer;
    }

    public function set layer(layer:Layer):void
    {
        _layer = layer;
        dataProvider = extractNonGroupLayerInfos(getSubLayerInfos(layer));
    }

    private function getSubLayerInfos(layer:Layer):Array
    {
        var layerInfos:Array;

        if (layer is ArcGISDynamicMapServiceLayer)
        {
            layerInfos = (layer as ArcGISDynamicMapServiceLayer).layerInfos;
        }
        else if (layer is ArcGISTiledMapServiceLayer)
        {
            layerInfos = (layer as ArcGISTiledMapServiceLayer).layerInfos;
        }
        else
        {
            layerInfos = [];
        }

        return layerInfos;
    }

    private function extractNonGroupLayerInfos(layerInfos:Array):ArrayList
    {
        var nonGroupLayerInfos:ArrayList = new ArrayList();
        var isGroupLayer:Boolean;
        for each (var layerInfo:LayerInfo in layerInfos)
        {
            isGroupLayer = (layerInfo.subLayerIds != null);
            if (!isGroupLayer)
            {
                nonGroupLayerInfos.addItem(layerInfo);
            }
        }

        return nonGroupLayerInfos;
    }
}
}
