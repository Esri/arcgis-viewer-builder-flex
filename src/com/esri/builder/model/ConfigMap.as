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

import com.esri.ags.SpatialReference;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.MapPoint;

public class ConfigMap implements IConstraints
{
    public var initExtent:Extent;
    public var fullExtent:Extent;
    public var center:MapPoint;
    public var level:int;
    public var scale:Number;
    public var itemId:String;
    public var esriLogoVisible:Boolean;
    public var openHandCursorVisible:Boolean;
    public var panEasingFactor:Number;
    public var scaleBarVisible:Boolean;
    public var attributionVisible:Boolean;
    public var scaleBarStyle:String = "default";
    public var zoomSliderVisible:Boolean;
    public var wkid:Number;
    public var wkt:String;
    public var wrapAround180:Boolean;
    public var basemaps:ConfigLayerStore = new ConfigLayerStore();
    public var operationalLayers:ConfigLayerStore = new ConfigLayerStore();
    public var lods:Array;
    [Bindable]
    public var addArcGISBasemaps:Boolean;

    private var _constraints:IConstraints = new Constraints();

    public function get left():String
    {
        return _constraints.left;
    }

    public function set left(value:String):void
    {
        _constraints.left = value;
    }

    public function get top():String
    {
        return _constraints.top;
    }

    public function set top(value:String):void
    {
        _constraints.top = value;
    }

    public function get right():String
    {
        return _constraints.right;
    }

    public function set right(value:String):void
    {
        _constraints.right = value;
    }

    public function get bottom():String
    {
        return _constraints.bottom;
    }

    public function set bottom(value:String):void
    {
        _constraints.bottom = value;
    }

    public static function decodeXML(mapXML:XML):ConfigMap
    {
        const configMap:ConfigMap = new ConfigMap();
        configMap.attributionVisible = mapXML.@attributionvisible != "false";
        configMap.initExtent = toExtent(mapXML.@initialextent);
        configMap.fullExtent = toExtent(mapXML.@fullextent);
        configMap.center = toMapPoint(mapXML.@center);
        configMap.level = mapXML.@level;
        configMap.scale = mapXML.@scale || Number.NaN;
        configMap.top = mapXML.@top;
        configMap.bottom = mapXML.@bottom;
        configMap.left = mapXML.@left;
        configMap.right = mapXML.@right;
        configMap.itemId = mapXML.@itemid;
        configMap.panEasingFactor = mapXML.@paneasingfactor;
        const esrilogovisible:String = mapXML.@esrilogovisible;
        configMap.esriLogoVisible = esrilogovisible !== 'false';
        const openhandcursorvisible:String = mapXML.@openhandcursorvisible;
        configMap.openHandCursorVisible = openhandcursorvisible == 'true';
        const zoomslidervisible:String = mapXML.@zoomslidervisible;
        configMap.zoomSliderVisible = zoomslidervisible === 'true';
        const scalebarvisible:String = mapXML.@scalebarvisible;
        configMap.scaleBarVisible = scalebarvisible !== 'false';
        if (mapXML.@scalebar[0])
        {
            configMap.scaleBarStyle = mapXML.@scalebar[0];
        }
        configMap.wkid = parseFloat(mapXML.@wkid);
        configMap.wkt = mapXML.@wkt;
        const wraparound180:String = mapXML.@wraparound180;
        configMap.wrapAround180 = wraparound180 === 'true';
        configMap.lods = decodeXMLLODs(mapXML.lods.lod);
        configMap.basemaps.importLayers(decodeXMLLayers(mapXML.basemaps.layer));
        configMap.operationalLayers.importLayers(decodeXMLLayers(mapXML.operationallayers.layer));
        configMap.addArcGISBasemaps = PortalModel.getInstance().portalURL && (mapXML.@addarcgisbasemaps == 'true');
        return configMap;
    }

    private static function decodeXMLLayers(xmlList:XMLList):Array
    {
        const arr:Array = []
        for each (var layerXML:XML in xmlList)
        {
            arr.push(ConfigLayer.decodeXML(layerXML));
        }
        return arr;
    }

    private static function decodeXMLLODs(lodXMLList:XMLList):Array
    {
        const arr:Array = [];
        for each (var lodXML:XML in lodXMLList)
        {
            arr.push(ConfigLOD.decodeXML(lodXML));
        }
        return arr;
    }

    private static function toMapPoint(attr:String):MapPoint
    {
        if (attr)
        {
            const tokens:Array = attr.split(/\s+/);
            if (tokens.length === 2)
            {
                const x:Number = parseFloat(tokens[0]);
                const y:Number = parseFloat(tokens[1]);
                if (!isNaN(x) && !isNaN(y))
                {
                    return new MapPoint(x, y);
                }
            }
        }
        return null;
    }

    private static function toExtent(attr:String):Extent
    {
        if (attr)
        {
            const tokens:Array = attr.split(/\s+/);
            if (tokens.length === 4)
            {
                const xmin:Number = parseFloat(tokens[0]);
                const ymin:Number = parseFloat(tokens[1]);
                const xmax:Number = parseFloat(tokens[2]);
                const ymax:Number = parseFloat(tokens[3]);
                if (!isNaN(xmin) && !isNaN(ymin) && !isNaN(xmax) && !isNaN(ymax))
                {
                    return new Extent(xmin, ymin, xmax, ymax);
                }
            }
        }
        return null;
    }

    public function encodeXML():XML
    {
        const mapXML:XML = <map/>;
        addAttributes(mapXML);
        addLODS(mapXML);
        addBasemapLayers(mapXML);
        addOperationalLayers(mapXML);
        return mapXML;
    }

    private function addOperationalLayers(mapXML:XML):void
    {
        if (!itemId && operationalLayers.hasLayers)
        {
            const operationalLayersXML:XML = <operationallayers/>;
            operationalLayersXML.appendChild(operationalLayers.toXML());
            mapXML.appendChild(operationalLayersXML);
        }
    }

    private function addBasemapLayers(mapXML:XML):void
    {
        if (!itemId && basemaps.hasLayers)
        {
            const basemapsXML:XML = <basemaps/>;
            basemapsXML.appendChild(basemaps.toXML());
            mapXML.appendChild(basemapsXML);
        }
    }

    private function addLODS(mapXML:XML):void
    {
        if (!itemId && lods && lods.length)
        {
            const lodsXML:XML = <lods/>;
            for each (var lod:ConfigLOD in lods)
            {
                lodsXML.appendChild(lod.encodeXML());
            }
            mapXML.appendChild(lodsXML);
        }
    }

    private function addAttributes(mapXML:XML):void
    {
        mapXML.@attributionvisible = attributionVisible;
        mapXML.@esrilogovisible = esriLogoVisible;
        mapXML.@openhandcursorvisible = openHandCursorVisible;
        mapXML.@scalebarvisible = scaleBarVisible;
        mapXML.@scalebar = scaleBarStyle;
        mapXML.@zoomslidervisible = zoomSliderVisible;
        mapXML.@wraparound180 = wrapAround180;
        mapXML.@addarcgisbasemaps = addArcGISBasemaps;
        if (initExtent)
        {
            mapXML.@initialextent = extent2attr(initExtent);
        }
        if (fullExtent)
        {
            mapXML.@fullextent = extent2attr(fullExtent);
        }
        if (panEasingFactor)
        {
            mapXML.@paneasingfactor;
        }
        if (itemId)
        {
            mapXML.@itemid = itemId;
        }
        else
        {
            if (center)
            {
                mapXML.@center = point2attr(center);
            }
            if (level)
            {
                mapXML.@level = level;
            }
            if (!isNaN(scale))
            {
                mapXML.@scale = scale;
            }
            if (initExtent && initExtent.spatialReference)
            {
                var spatialReference:SpatialReference = initExtent.spatialReference;
                setSpatialReferenceAttributes(spatialReference.wkid, spatialReference.wkt, mapXML);
            }
            else
            {
                setSpatialReferenceAttributes(wkid, wkt, mapXML);
            }
        }
        if (left)
        {
            mapXML.@left = left;
        }
        if (right)
        {
            mapXML.@right = right;
        }
        if (top)
        {
            mapXML.@top = top;
        }
        if (bottom)
        {
            mapXML.@bottom = bottom;
        }
        if (PortalModel.getInstance().portalURL)
        {
            mapXML.@portalurl = PortalModel.getInstance().portalURL;
        }
    }

    private function setSpatialReferenceAttributes(wkid:Number, wkt:String, mapXML:XML):void
    {
        if (!isNaN(wkid))
        {
            mapXML.@wkid = wkid;
        }
        if (wkt)
        {
            mapXML.@wkt = wkt;
        }
    }

    private function point2attr(mapPoint:MapPoint):String
    {
        return mapPoint.x + " " + mapPoint.y;
    }

    private function extent2attr(extent:Extent):String
    {
        const arr:Array = [];
        arr.push(extent.xmin.toString());
        arr.push(extent.ymin.toString());
        arr.push(extent.xmax.toString());
        arr.push(extent.ymax.toString());
        return arr.join(' ');
    }
}
}
