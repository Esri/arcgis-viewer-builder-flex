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

import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISImageServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.ArcIMSMapServiceLayer;
import com.esri.ags.layers.CSVLayer;
import com.esri.ags.layers.FeatureLayer;
import com.esri.ags.layers.GeoRSSLayer;
import com.esri.ags.layers.KMLLayer;
import com.esri.ags.layers.Layer;
import com.esri.ags.layers.OpenStreetMapLayer;
import com.esri.ags.layers.WMSLayer;
import com.esri.ags.layers.WMTSLayer;
import com.esri.ags.layers.WebTiledLayer;
import com.esri.ags.virtualearth.VETiledLayer;
import com.esri.builder.supportClasses.LayerToXMLUtil;
import com.esri.builder.supportClasses.URLUtil;

import mx.utils.StringUtil;

[RemoteClass]
[Bindable]
public final class ConfigLayer
{
    public static const TILED:String = "tiled";
    public static const DYNAMIC:String = "dynamic";
    public static const FEATURE:String = "feature";
    public static const IMAGE:String = "image";
    public static const KML:String = "kml";
    public static const OSM:String = "osm";
    public static const BING:String = "bing";
    public static const ARC_IMS:String = "arcims";
    public static const WEB_TILED:String = "webtiled";
    public static const WMS:String = "wms";
    public static const WMTS:String = "wmts";
    public static const CSV:String = "csv";
    public static const GEO_RSS:String = "georss";

    public static const TILED_LABEL:String = "tiled service";
    public static const DYNAMIC_LABEL:String = "dynamic service";
    public static const FEATURE_LABEL:String = "feature layer";
    public static const IMAGE_LABEL:String = "image service";
    public static const KML_LABEL:String = "kml layer";
    public static const WEB_TILED_LABEL:String = "web tiled layer";

    private const MAP_SERVER_SOURCE:String = "\u202A(MS)\u202C";
    private const FEATURE_SERVER_SOURCE:String = "\u202A(FS)\u202C";

    [Transient]
    public var layerXML:XML; // The original XML

    public var label:String;

    public var type:String;

    public function get prettyType():String
    {
        var label:String;

        switch (type)
        {
            case TILED:
            {
                label = TILED_LABEL;
                break;
            }
            case DYNAMIC:
            {
                label = DYNAMIC_LABEL;
                break;
            }
            case FEATURE:
            {
                label = FEATURE_LABEL;
                break;
            }
            case IMAGE:
            {
                label = IMAGE_LABEL;
                break;
            }
            case KML:
            {
                label = KML_LABEL;
                break;
            }
            case WEB_TILED:
            {
                label = WEB_TILED_LABEL;
                break;
            }
            default:
            {
                //no custom label needed
                label = type;
            }
        }

        return StringUtil.trim(StringUtil.substitute("{0} {1}",
                                                     label,
                                                     layerSourceLabel));
    }

    public function get layerSourceLabel():String
    {
        const mapServerLayer:RegExp = /MapServer\/[0-9]+\/?$/;
        const featureServerLayer:RegExp = /FeatureServer\/[0-9]+\/?$/;

        var label:String;

        if (mapServerLayer.test(URLUtil.removeQueryString(url)))
        {
            label = MAP_SERVER_SOURCE;
        }
        else if (featureServerLayer.test(URLUtil.removeQueryString(url)))
        {
            label = FEATURE_SERVER_SOURCE;
        }
        else
        {
            label = "";
        }

        return label;
    }

    public var alpha:Number = 1;

    public var copyright:String;

    public var icon:String;

    public var autoRefresh:int;

    public var displayLevels:String;

    public var imageFormat:String;

    public var token:String;

    public var _url:String;

    public function get url():String
    {
        return _url;
    }

    public function set url(value:String):void
    {
        var urlToken:String = URLUtil.extractToken(value);
        if (urlToken)
        {
            token = urlToken;
        }
        _url = URLUtil.removeToken(value);
    }

    public var useProxy:Boolean;

    public var useMapTime:Boolean;

    public var visible:Boolean;

    public var visibleLayers:String;

    public var reference:Boolean;

    // Attributes specific for layers of type image:
    public var bandIds:String;

    // Attributes specific for layers of type feature:
    public var popupConfig:String;

    public var info:String;

    public var infoConfig:String;

    public var mode:String;

    public var definitionExpression:String;

    public var useAMF:Boolean = true;

    // Attributes specific for Bing Maps:
    public var style:String;

    public var culture:String;

    // Attributes specific for ArcIMS:
    public var serviceHost:String;

    public var serviceName:String;

    // Attributes specific for WMS:
    public var skipGetCapabilities:Boolean;

    public var version:String;

    public var wkid:String;

    public var subLayers:Array;

    public var clustering:Clustering;

    public var gdbVersion:String;

    public var minScale:Number;

    public var maxScale:Number;

    public var isEditable:String;

    public var username:String;
    public var password:String;
    public var maxImageHeight:String;
    public var maxImageWidth:String;
    public var showInLegend:String;
    public var showInLegendHiddenLayers:String;

    /*CSV*/
    public var longitudeFieldName:String;
    public var latitudeFieldName:String;
    public var columnDelimiter:String;
    public var sourceFields:String;

    /*GeoRSS*/
    public var pictureMarkerSymbol:XML;
    public var simpleMarkerSymbol:XML;
    public var simpleLineSymbol:XML;
    public var simpleFillSymbol:XML;

    /*Web Tiled*/
    public var subDomains:String;

    /*WMTS*/
    public var serviceMode:String;
    public var layerId:String;
    public var tileMatrixSetId:String;

    public static function decodeXML(layerXML:XML):ConfigLayer
    {
        const configLayer:ConfigLayer = new ConfigLayer();
        configLayer.layerXML = layerXML;
        configLayer.label = layerXML.@label;
        configLayer.type = layerXML.@type;
        configLayer.alpha = layerXML.@alpha || 1.0;
        configLayer.copyright = layerXML.@copyright[0];
        configLayer.icon = layerXML.@icon;
        configLayer.autoRefresh = layerXML.@autorefresh || 0;
        var displayLevels:XMLList = layerXML.@displaylevels;
        // TODO - configLayer.displayLevels = displayLevels;
        var imageFormat:String = layerXML.@imageformat[0];
        var isDynamic:Boolean = (configLayer.type == DYNAMIC);
        configLayer.imageFormat = isDynamic ? toKnownImageFormat(imageFormat) : imageFormat;
        configLayer.token = layerXML.@token;
        configLayer.url = layerXML.@url;
        const useproxy:String = layerXML.@useproxy;
        configLayer.useProxy = useproxy === 'true';
        const usemaptime:String = layerXML.@usemaptime;
        configLayer.useMapTime = usemaptime === 'true';
        const visible:String = layerXML.@visible;
        configLayer.visible = visible !== 'false';
        configLayer.bandIds = layerXML.@bandids;
        configLayer.pictureMarkerSymbol = layerXML.picturemarkersymbol[0];
        configLayer.simpleMarkerSymbol = layerXML.simplemarkersymbol[0];
        configLayer.simpleFillSymbol = layerXML.simplefillsymbol[0];
        configLayer.simpleLineSymbol = layerXML.simplelinesymbol[0];
        configLayer.popupConfig = layerXML.@popupconfig;
        configLayer.gdbVersion = layerXML.@gdbversion;
        configLayer.info = layerXML.@info;
        configLayer.infoConfig = layerXML.@infoconfig;
        configLayer.mode = layerXML.@mode;
        configLayer.definitionExpression = layerXML.@definitionexpression;
        const useamf:String = layerXML.@useamf;
        configLayer.useAMF = useamf !== 'false';
        configLayer.style = layerXML.@style;
        configLayer.culture = layerXML.@culture;
        configLayer.serviceHost = layerXML.@servicehost;
        configLayer.serviceName = layerXML.@servicename;
        const skipgetcapabilities:String = layerXML.@skipgetcapabilities;
        configLayer.skipGetCapabilities = skipgetcapabilities == 'true';
        configLayer.version = layerXML.@version;
        configLayer.wkid = layerXML.@wkid;
        const reference:String = layerXML.@reference;
        configLayer.reference = reference === 'true';
        configLayer.visibleLayers = layerXML.@visiblelayers;
        configLayer.subLayers = [];
        for each (var subLayerXML:XML in layerXML.sublayer)
        {
            configLayer.subLayers.push(ConfigSubLayer.decodeXML(subLayerXML));
        }
        if (layerXML.clustering[0])
        {
            configLayer.clustering = Clustering.decodeXML(layerXML.clustering[0]);
        }

        configLayer.columnDelimiter = layerXML.@columndelimiter[0];
        configLayer.longitudeFieldName = layerXML.@longitudefieldname[0];
        configLayer.latitudeFieldName = layerXML.@latitudefieldname[0];
        configLayer.sourceFields = layerXML.@sourcefields[0];
        configLayer.minScale = layerXML.@minscale[0];
        configLayer.maxScale = layerXML.@maxscale[0];
        configLayer.isEditable = layerXML.@iseditable[0];
        configLayer.username = layerXML.@username[0];
        configLayer.password = layerXML.@password[0];
        configLayer.maxImageHeight = layerXML.@maximageheight[0];
        configLayer.maxImageWidth = layerXML.@maximagewidth[0];
        configLayer.tileMatrixSetId = layerXML.@tilematrixsetid[0];
        configLayer.showInLegend = layerXML.@showinlegend[0];
        configLayer.showInLegendHiddenLayers = layerXML.@showinlegendhiddenlayers[0];
        configLayer.subDomains = layerXML.@subdomains[0];
        configLayer.layerId = layerXML.@layerid[0];
        configLayer.serviceMode = layerXML.@servicemode[0];

        return configLayer;
    }

    private static function toKnownImageFormat(imageFormat:String):String
    {
        var knownFormat:String;

        switch (imageFormat)
        {
            case "png24":
            case "png32":
            case "jpg":
            case "gif":
            {
                knownFormat = imageFormat;
                break;
            }
            default:
            {
                knownFormat = "png8";
            }
        }

        return knownFormat;
    }

    public function encodeXML():XML
    {
        const layerXML:XML = <layer type={type}/>;
        if (label)
        {
            layerXML.@label = label;
        }
        if (!isNaN(alpha) && alpha < 1.0)
        {
            layerXML.@alpha = alpha;
        }
        if (copyright != null) //empty copyright ("") allowed
        {
            layerXML.@copyright = copyright;
        }
        if (icon)
        {
            layerXML.@icon = icon;
        }
        if (autoRefresh)
        {
            layerXML.@autorefresh = autoRefresh;
        }
        if (displayLevels)
        {
            layerXML.@displaylevels = displayLevels;
        }
        if (gdbVersion)
        {
            layerXML.@gdbversion = gdbVersion;
        }
        if (imageFormat)
        {
            layerXML.@imageformat = imageFormat;
        }
        if (token)
        {
            layerXML.@token = token;
        }
        if (url)
        {
            layerXML.@url = url;
        }
        if (bandIds)
        {
            layerXML.@bandids = bandIds;
        }
        if (popupConfig)
        {
            layerXML.@popupconfig = popupConfig;
        }
        if (info)
        {
            layerXML.@info = info;
        }
        if (infoConfig)
        {
            layerXML.@infoconfig = infoConfig;
        }
        if (mode)
        {
            layerXML.@mode = mode;
        }
        if (definitionExpression)
        {
            layerXML.@definitionexpression = definitionExpression;
        }
        if (type === 'feature' && !useAMF)
        {
            layerXML.@useamf = useAMF;
        }
        if (type === 'bing')
        {
            if (culture)
            {
                layerXML.@culture = culture;
            }
        }
        if (type === 'arcims')
        {
            if (serviceHost)
            {
                layerXML.@servicehost = serviceHost;
            }
            if (serviceName)
            {
                layerXML.@servicename = serviceName;
            }
        }
        if (type === 'wms')
        {
            if (skipGetCapabilities)
            {
                layerXML.@skipgetcapabilities = skipGetCapabilities;
            }
            if (version)
            {
                layerXML.@version = version;
            }
            if (wkid)
            {
                layerXML.@wkid = wkid;
            }
        }
        layerXML.@visible = visible;
        if (visibleLayers)
        {
            layerXML.@visiblelayers = visibleLayers;
        }
        if (useProxy)
        {
            layerXML.@useproxy = useProxy;
        }
        if (useMapTime)
        {
            layerXML.@usemaptime = useMapTime;
        }
        if (reference)
        {
            layerXML.@reference = reference;
        }
        if (subLayers && subLayers.length)
        {
            for each (var subLayer:ConfigSubLayer in subLayers)
            {
                layerXML.appendChild(subLayer.encodeXML());
            }
        }
        if (clustering)
        {
            layerXML.appendChild(clustering.encodeXML());
        }

        if (columnDelimiter)
        {
            layerXML.@columndelimiter = columnDelimiter;
        }
        if (longitudeFieldName)
        {
            layerXML.@longitudefieldname = longitudeFieldName;
        }
        if (latitudeFieldName)
        {
            layerXML.@latitudefieldname = latitudeFieldName;
        }
        if (sourceFields)
        {
            layerXML.@sourcefields = sourceFields;
        }
        if (!isNaN(minScale) && minScale > 0)
        {
            layerXML.@minscale = minScale;
        }
        if (!isNaN(maxScale) && maxScale > 0)
        {
            layerXML.@maxscale = maxScale;
        }
        if (isEditable == "false")
        {
            layerXML.@iseditable = isEditable;
        }
        if (subDomains)
        {
            layerXML.@subdomains = subDomains;
        }
        if (layerId)
        {
            layerXML.@layerid = layerId;
        }
        if (serviceMode)
        {
            layerXML.@servicemode = serviceMode;
        }
        if (style)
        {
            layerXML.@style = style;
        }
        if (simpleMarkerSymbol)
        {
            layerXML.appendChild(simpleMarkerSymbol);
        }
        if (pictureMarkerSymbol)
        {
            layerXML.appendChild(pictureMarkerSymbol);
        }
        if (simpleLineSymbol)
        {
            layerXML.appendChild(simpleLineSymbol);
        }
        if (simpleFillSymbol)
        {
            layerXML.appendChild(simpleFillSymbol);
        }
        if (username)
        {
            layerXML.@username = username;
        }
        if (password)
        {
            layerXML.@password = password;
        }
        if (maxImageHeight)
        {
            layerXML.@maximageheight = maxImageHeight;
        }
        if (maxImageWidth)
        {
            layerXML.@maximagewidth = maxImageWidth;
        }
        if (tileMatrixSetId)
        {
            layerXML.@tilematrixsetid = tileMatrixSetId;
        }
        if (showInLegend != "false")
        {
            if (showInLegendHiddenLayers)
            {
                layerXML.@showinlegendhiddenlayers = showInLegendHiddenLayers;
            }
        }
        else
        {
            layerXML.@showinlegend = showInLegend;
        }

        return layerXML;
    }

    public function createLayer():Layer
    {
        var layer:Layer;

        switch (type)
        {
            case ConfigLayer.DYNAMIC:
            {
                layer = new ArcGISDynamicMapServiceLayer(url);
                break;
            }
            case ConfigLayer.TILED:
            {
                layer = new ArcGISTiledMapServiceLayer(url);
                break;
            }
            case ConfigLayer.FEATURE:
            {
                layer = new FeatureLayer(url);
                break;
            }
            case ConfigLayer.IMAGE:
            {
                layer = new ArcGISImageServiceLayer(url);
                break;
            }
            case ConfigLayer.KML:
            {
                layer = new KMLLayer(url);
                break;
            }
            case ConfigLayer.GEO_RSS:
            {
                layer = new GeoRSSLayer(url);
                break;
            }
            case ConfigLayer.OSM:
            {
                layer = new OpenStreetMapLayer();
                break;
            }
            case ConfigLayer.BING:
            {
                var veLayer:VETiledLayer = new VETiledLayer();
                veLayer.key = Model.instance.bingKey;
                layer = veLayer;
                break;
            }
            case ConfigLayer.ARC_IMS:
            {
                //TODO: add missing properties when arcims type supported
                layer = new ArcIMSMapServiceLayer(url);
                break;
            }
            case ConfigLayer.CSV:
            {
                layer = new CSVLayer(url);
                break;
            }
            case ConfigLayer.WMS:
            {
                layer = new WMSLayer(url);
                break;
            }
            case ConfigLayer.WMTS:
            {
                layer = new WMTSLayer(url);
                break;
            }
            case ConfigLayer.WEB_TILED:
            {
                layer = new WebTiledLayer(url);
                break;
            }
        }

        return layer;
    }

    /*
    * helper method to keep track of currently unsupported layers
    */
    public function get isLayerSupported():Boolean
    {
        return type != ConfigLayer.ARC_IMS;
    }

    public static function operationalLayerToXML(layer:Layer, label:String):XML
    {
        return LayerToXMLUtil.operationalLayerToXML(layer, label);
    }

    public static function basemapLayerToXML(layer:Layer, label:String):XML
    {
        return LayerToXMLUtil.basemapLayerToXML(layer, label);
    }

    public static function basemapConfigLayerFromLayer(layer:Layer, label:String):ConfigLayer
    {
        var configLayer:ConfigLayer;

        const basemapLayerXML:XML = basemapLayerToXML(layer, label);
        if (basemapLayerXML)
        {
            configLayer = decodeXML(basemapLayerXML);
        }

        return configLayer;
    }

    public static function operationalConfigLayerFromLayer(layer:Layer, label:String):ConfigLayer
    {
        var configLayer:ConfigLayer;

        const operationalLayerXML:XML = operationalLayerToXML(layer, label);
        if (operationalLayerXML)
        {
            configLayer = decodeXML(operationalLayerXML);
        }

        return configLayer;
    }
}

}
