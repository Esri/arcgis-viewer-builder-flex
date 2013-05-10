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
import com.esri.ags.layers.supportClasses.Field;
import com.esri.ags.layers.supportClasses.LayerDefinition;
import com.esri.ags.layers.supportClasses.TileInfo;
import com.esri.ags.symbols.PictureMarkerSymbol;
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.symbols.Symbol;
import com.esri.ags.virtualearth.VETiledLayer;

import flash.utils.ByteArray;

import mx.utils.Base64Encoder;
import mx.utils.ObjectUtil;
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

    private const MAP_SERVER_SOURCE:String = "(MS)";
    private const FEATURE_SERVER_SOURCE:String = "(FS)";

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

        if (mapServerLayer.test(url))
        {
            label = MAP_SERVER_SOURCE;
        }
        else if (featureServerLayer.test(url))
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

    public var url:String;

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
        if (configLayer.type == DYNAMIC)
        {
            configLayer.imageFormat = parseImageFormat(layerXML.@imageformat[0]);
        }
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

        return configLayer;
    }

    private static function parseImageFormat(imageFormat:String):String
    {
        var parsedImageFormat:String;

        switch (imageFormat)
        {
            case "png24":
            case "png32":
            case "jpg":
            case "gif":
            {
                parsedImageFormat = imageFormat;
            }
            default:
            {
                parsedImageFormat = "png8";
            }
        }

        return parsedImageFormat;
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
            layerXML.@mode = serviceMode;
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
        const layerXML:XML = layerToXML(layer, label);

        if (layerXML)
        {
            if (layer.minScale > 0)
            {
                layerXML.@minscale = layer.minScale;
            }
            if (layer.maxScale > 0)
            {
                layerXML.@maxscale = layer.maxScale;
            }
        }

        return layerXML;
    }

    private static function layerToXML(layer:Layer, label:String):XML
    {
        var lyrXML:XML;

        if (layer is ArcGISDynamicMapServiceLayer)
        {
            var dynLyr:ArcGISDynamicMapServiceLayer = layer as ArcGISDynamicMapServiceLayer;
            lyrXML = <layer label={label}
                    type="dynamic"
                    visible={dynLyr.visible}
                    alpha={dynLyr.alpha}
                    url={dynLyr.url}
                    useproxy={dynLyr.proxyURL != null}/>;
            if (dynLyr.showInLegend)
            {
                if (dynLyr.showInLegendHiddenLayers)
                {
                    lyrXML.@showinlegendhiddenlayers = dynLyr.showInLegendHiddenLayers.join();
                }
            }
            else
            {
                lyrXML.@showinlegend = false;
            }
            if (dynLyr.visibleLayers)
            {
                lyrXML.@visiblelayers = dynLyr.visibleLayers.toArray().join();
            }
            if (dynLyr.layerDefinitions && dynLyr.layerDefinitions.length > 0)
            {
                // <sublayer id="2" definitionexpression="AGBUR = 'BIA'"/>
                for each (var layerDefinition:LayerDefinition in dynLyr.layerDefinitions)
                {
                    lyrXML.appendChild(<sublayer id={layerDefinition.layerId} definitionexpression={layerDefinition.definition}/>);
                }
            }
        }
        else if (layer is ArcGISImageServiceLayer)
        {
            var imgLyr:ArcGISImageServiceLayer = layer as ArcGISImageServiceLayer;
            lyrXML = <layer label={label}
                    type="image"
                    visible={imgLyr.visible}
                    alpha={imgLyr.alpha}
                    url={imgLyr.url}
                    useproxy={imgLyr.proxyURL != null}/>;
            if (!imgLyr.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
            if (imgLyr.bandIds)
            {
                lyrXML.@bandids = imgLyr.bandIds.join();
            }
        }
        else if (layer is ArcGISTiledMapServiceLayer)
        {
            var tiledLyr:ArcGISTiledMapServiceLayer = layer as ArcGISTiledMapServiceLayer;
            lyrXML = <layer label={label}
                    type="tiled"
                    visible={tiledLyr.visible}
                    alpha={tiledLyr.alpha}
                    url={tiledLyr.url}
                    useproxy={tiledLyr.proxyURL != null}/>;
            if (tiledLyr.showInLegend)
            {
                if (tiledLyr.showInLegendHiddenLayers)
                {
                    lyrXML.@showinlegendhiddenlayers = tiledLyr.showInLegendHiddenLayers.join();
                }
            }
            else
            {
                lyrXML.@showinlegend = false;
            }
            if (tiledLyr.displayLevels)
            {
                lyrXML.@displaylevels = tiledLyr.displayLevels.join();
            }
        }
        else if (layer is CSVLayer)
        {
            var csvLyr:CSVLayer = layer as CSVLayer;
            lyrXML = <layer label={label}
                    type="csv"
                    visible={csvLyr.visible}
                    alpha={csvLyr.alpha}
                    url={csvLyr.url}
                    longitudefieldname={csvLyr.longitudeFieldName}
                    latitudefieldname={csvLyr.latitudeFieldName}/>;
            if (!csvLyr.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
            if (csvLyr.columnDelimiter != ",")
            {
                lyrXML.@columndelimiter = csvLyr.columnDelimiter;
            }
            if (csvLyr.sourceFields)
            {
                var fields:Array = [];
                for each (var field:Field in csvLyr.sourceFields)
                {
                    fields.push(field.name + "|" + field.alias + "|" + field.type);
                }
                lyrXML.@sourcefields = fields.join();
            }
        }
        else if (layer is FeatureLayer && !(layer is CSVLayer))
        {
            var feaLyr:FeatureLayer = layer as FeatureLayer;
            if (!feaLyr.featureCollection)
            {
                lyrXML = <layer label={label}
                        type="feature"
                        visible={feaLyr.visible}
                        alpha={feaLyr.alpha}
                        mode={feaLyr.mode}
                        url={feaLyr.url}
                        iseditable={feaLyr.isEditable}
                        useproxy={feaLyr.proxyURL != null}/>;
                if (!feaLyr.showInLegend)
                {
                    lyrXML.@showinlegend = false;
                }
            }
        }
        else if (layer is GeoRSSLayer)
        {
            var geoRSSLayer:GeoRSSLayer = layer as GeoRSSLayer;
            lyrXML = <layer label={label}
                    type="georss"
                    visible={geoRSSLayer.visible}
                    alpha={geoRSSLayer.alpha}
                    url={geoRSSLayer.url}/>;
            if (!geoRSSLayer.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
            if (geoRSSLayer.serviceURL)
            {
                lyrXML.@serviceurl = geoRSSLayer.serviceURL;
            }
            if (geoRSSLayer.pointSymbol)
            {
                lyrXML.appendChild(getPointSymbolXML(geoRSSLayer.pointSymbol));
            }
            if (geoRSSLayer.polylineSymbol)
            {
                lyrXML.appendChild(getLineSymbolXML(geoRSSLayer.polylineSymbol));
            }
            if (geoRSSLayer.polygonSymbol)
            {
                lyrXML.appendChild(getPolygonSymbolXML(geoRSSLayer.polygonSymbol));
            }
        }
        else if (layer is KMLLayer)
        {
            var kmlLyr:KMLLayer = layer as KMLLayer;
            lyrXML = <layer label={label}
                    type="kml"
                    visible={kmlLyr.visible}
                    alpha={kmlLyr.alpha}
                    url={kmlLyr.url}/>;
            if (!kmlLyr.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
        }
        else if (layer is OpenStreetMapLayer)
        {
            var osmLyr:OpenStreetMapLayer = layer as OpenStreetMapLayer;
            lyrXML = <layer label={label}
                    type="osm"
                    visible={osmLyr.visible}
                    alpha={osmLyr.alpha}/>;
            if (!osmLyr.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
        }
        else if (layer is VETiledLayer)
        {
            var veLyr:VETiledLayer = layer as VETiledLayer;
            lyrXML = <layer label={label}
                    type="bing"
                    visible={veLyr.visible}
                    alpha={veLyr.alpha}
                    style={veLyr.mapStyle}/>;
            if (!veLyr.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
            if (veLyr.displayLevels)
            {
                lyrXML.@displaylevels = veLyr.displayLevels.join();
            }
        }
        else if (layer is WMSLayer)
        {
            var wmsLayer:WMSLayer = layer as WMSLayer;
            lyrXML = <layer label={label}
                    type="wms"
                    visible={wmsLayer.visible}
                    alpha={wmsLayer.alpha}
                    version={wmsLayer.version}
                    skipgetcapabilities={wmsLayer.skipGetCapabilities}
                    imageformat={wmsLayer.imageFormat}
                    url={wmsLayer.url}/>;
            if (!wmsLayer.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
            if (wmsLayer.copyright)
            {
                lyrXML.@copyright = wmsLayer.copyright;
            }
            if (wmsLayer.spatialReference)
            {
                lyrXML.@wkid = wmsLayer.spatialReference.wkid;
            }
            if (wmsLayer.maxImageHeight > 0)
            {
                lyrXML.@maximageheight = wmsLayer.maxImageHeight;
            }
            if (wmsLayer.maxImageWidth > 0)
            {
                lyrXML.@maximagewidth = wmsLayer.maxImageWidth;
            }
            if (wmsLayer.visibleLayers)
            {
                lyrXML.@visiblelayers = wmsLayer.visibleLayers.toArray().join();
            }
        }
        else if (layer is WMTSLayer)
        {
            var wmtsLayer:WMTSLayer = layer as WMTSLayer;
            lyrXML = <layer label={label}
                    type="wmts"
                    visible={wmtsLayer.visible}
                    alpha={wmtsLayer.alpha}
                    version={wmtsLayer.version}
                    imageformat={wmtsLayer.imageFormat}
                    url={wmtsLayer.url}
                    useproxy={tiledLyr.proxyURL != null}/>;
            if (!wmtsLayer.showInLegend)
            {
                lyrXML.@showinlegend = false;
            }
            if (wmtsLayer.layerId)
            {
                lyrXML.@layerid = wmtsLayer.layerId;
            }
            if (wmtsLayer.serviceMode)
            {
                lyrXML.@mode = wmtsLayer.serviceMode;
            }
            if (wmtsLayer.style)
            {
                lyrXML.@style = wmtsLayer.style;
            }
        }
        else if (layer is WebTiledLayer)
        {
            var webTiledLayer:WebTiledLayer = layer as WebTiledLayer;
            var defaultWebTiledLayer:WebTiledLayer = new WebTiledLayer();
            var defaultTileInfo:TileInfo = defaultWebTiledLayer.tileInfo;

            var hasSupportedTileInfo:Boolean = ObjectUtil.compare(defaultTileInfo, webTiledLayer.tileInfo) == 0;
            if (hasSupportedTileInfo)
            {
                lyrXML = <layer label={label}
                        type="webtiled"
                        visible={webTiledLayer.visible}
                        alpha={webTiledLayer.alpha}
                        url={webTiledLayer.urlTemplate}/>;
                if (!webTiledLayer.showInLegend)
                {
                    lyrXML.@showinlegend = false;
                }
                if (webTiledLayer.copyright)
                {
                    lyrXML.@copyright = webTiledLayer.copyright;
                }
                if (webTiledLayer.displayLevels)
                {
                    lyrXML.@displaylevels = webTiledLayer.displayLevels.join();
                }
                if (webTiledLayer.subDomains)
                {
                    lyrXML.@subdomains = webTiledLayer.subDomains.join();
                }
            }
        }

        return lyrXML;
    }

    private static function getPointSymbolXML(pointSymbol:Symbol):XML
    {
        var pointSymbolXML:XML;

        if (pointSymbol)
        {
            if (pointSymbol is SimpleMarkerSymbol)
            {
                var sms:SimpleMarkerSymbol = pointSymbol as SimpleMarkerSymbol;

                pointSymbolXML = <simplemarkersymbol
                        alpha={sms.alpha}
                        color={sms.color}
                        size={sms.size}
                        style={sms.style}/>;

                if (sms.outline)
                {
                    pointSymbolXML.appendChild(<outline
                                                   color={sms.outline.color}
                                                   width={sms.outline.width}
                                                   style={sms.outline.style}/>);
                }
            }
            else if (pointSymbol is PictureMarkerSymbol)
            {
                var pms:PictureMarkerSymbol = pointSymbol as PictureMarkerSymbol;

                pointSymbolXML = <picturemarkersymbol
                        height={pms.height}
                        width={pms.width}
                        xoffset={pms.xoffset}
                        yoffset={pms.yoffset}
                        angle={pms.angle}/>;

                var sourceData:ByteArray = pms.source as ByteArray;
                if (sourceData)
                {
                    var encoder:Base64Encoder = new Base64Encoder();
                    encoder.insertNewLines = false;
                    encoder.encodeBytes(sourceData)
                    pointSymbolXML.@source = encoder.toString();
                }
                else
                {
                    pointSymbolXML.@url = pms.source;
                }
            }
        }

        return pointSymbolXML;
    }

    private static function getLineSymbolXML(polylineSymbol:Symbol):XML
    {
        var polylineSymbolXML:XML;

        if (polylineSymbol)
        {
            var sls:SimpleLineSymbol = polylineSymbol as SimpleLineSymbol;

            polylineSymbolXML = <simplelinesymbol
                    alpha={sls.alpha}
                    color={sls.color}
                    width={sls.width}
                    style={sls.style}/>;
        }

        return polylineSymbolXML;
    }

    private static function getPolygonSymbolXML(polygonSymbol:Symbol):XML
    {
        var polygonSymbolXML:XML;

        if (polygonSymbol)
        {
            var sfs:SimpleFillSymbol = polygonSymbol as SimpleFillSymbol;

            polygonSymbolXML = <simplefillsymbol
                    alpha={sfs.alpha}
                    color={sfs.color}
                    style={sfs.style}/>;

            if (sfs.outline)
            {
                polygonSymbolXML.appendChild(<outline
                                                 color={sfs.outline.color}
                                                 width={sfs.outline.width}
                                                 style={sfs.outline.style}/>);
            }
        }

        return polygonSymbolXML;
    }

    public static function basemapLayerToXML(layer:Layer, label:String):XML
    {
        return layerToXML(layer, label);
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
