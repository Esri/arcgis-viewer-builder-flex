package com.esri.builder.supportClasses
{

import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISImageServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
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

public class LayerToXMLUtil
{
    public static function basemapLayerToXML(layer:Layer, label:String):XML
    {
        return layerToXML(layer, label);
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
        var layerXML:XML;

        if (layer is ArcGISDynamicMapServiceLayer)
        {
            var dynLayer:ArcGISDynamicMapServiceLayer = layer as ArcGISDynamicMapServiceLayer;

            layerXML = <layer label={label}
                    type="dynamic"
                    visible={dynLayer.visible}
                    alpha={dynLayer.alpha}
                    url={dynLayer.url}
                    useproxy={dynLayer.proxyURL != null}/>;

            if (dynLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(dynLayer.refreshInterval);
            }

            if (dynLayer.showInLegend)
            {
                if (dynLayer.showInLegendHiddenLayers)
                {
                    layerXML.@showinlegendhiddenlayers = dynLayer.showInLegendHiddenLayers.join();
                }
            }
            else
            {
                layerXML.@showinlegend = false;
            }

            if (dynLayer.visibleLayers)
            {
                layerXML.@visiblelayers = dynLayer.visibleLayers.toArray().join();
            }

            if (dynLayer.layerDefinitions && dynLayer.layerDefinitions.length > 0)
            {
                // <sublayer id="2" definitionexpression="AGBUR = 'BIA'"/>
                for each (var layerDefinition:LayerDefinition in dynLayer.layerDefinitions)
                {
                    layerXML.appendChild(<sublayer id={layerDefinition.layerId} definitionexpression={layerDefinition.definition}/>);
                }
            }
        }
        else if (layer is ArcGISImageServiceLayer)
        {
            var imgLayer:ArcGISImageServiceLayer = layer as ArcGISImageServiceLayer;

            layerXML = <layer label={label}
                    type="image"
                    visible={imgLayer.visible}
                    alpha={imgLayer.alpha}
                    url={imgLayer.url}
                    useproxy={imgLayer.proxyURL != null}/>;

            if (imgLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(imgLayer.refreshInterval);
            }

            if (!imgLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }

            if (imgLayer.bandIds)
            {
                layerXML.@bandids = imgLayer.bandIds.join();
            }
        }
        else if (layer is ArcGISTiledMapServiceLayer)
        {
            var tiledLayer:ArcGISTiledMapServiceLayer = layer as ArcGISTiledMapServiceLayer;
            layerXML = <layer label={label}
                    type="tiled"
                    visible={tiledLayer.visible}
                    alpha={tiledLayer.alpha}
                    url={tiledLayer.url}
                    useproxy={tiledLayer.proxyURL != null}/>;

            if (tiledLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(tiledLayer.refreshInterval);
            }

            if (tiledLayer.showInLegend)
            {
                if (tiledLayer.showInLegendHiddenLayers)
                {
                    layerXML.@showinlegendhiddenlayers = tiledLayer.showInLegendHiddenLayers.join();
                }
            }
            else
            {
                layerXML.@showinlegend = false;
            }

            if (tiledLayer.displayLevels)
            {
                layerXML.@displaylevels = tiledLayer.displayLevels.join();
            }
        }
        else if (layer is CSVLayer)
        {
            var csvLayer:CSVLayer = layer as CSVLayer;

            layerXML = <layer label={label}
                    type="csv"
                    visible={csvLayer.visible}
                    alpha={csvLayer.alpha}
                    url={csvLayer.url}
                    longitudefieldname={csvLayer.longitudeFieldName}
                    latitudefieldname={csvLayer.latitudeFieldName}/>;

            if (csvLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(csvLayer.refreshInterval);
            }

            if (!csvLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }

            if (csvLayer.columnDelimiter != ",")
            {
                layerXML.@columndelimiter = csvLayer.columnDelimiter;
            }

            if (csvLayer.sourceFields)
            {
                var fields:Array = [];
                for each (var field:Field in csvLayer.sourceFields)
                {
                    fields.push(field.name + "|" + field.alias + "|" + field.type);
                }
                layerXML.@sourcefields = fields.join();
            }
        }
        else if (layer is FeatureLayer && !(layer is CSVLayer))
        {
            var feaLayer:FeatureLayer = layer as FeatureLayer;

            if (!feaLayer.featureCollection)
            {
                layerXML = <layer label={label}
                        type="feature"
                        visible={feaLayer.visible}
                        alpha={feaLayer.alpha}
                        mode={feaLayer.mode}
                        url={feaLayer.url}
                        iseditable={feaLayer.isEditable}
                        useproxy={feaLayer.proxyURL != null}/>;

                if (feaLayer.refreshInterval > 0)
                {
                    layerXML.@autorefresh = minutesToSeconds(feaLayer.refreshInterval);
                }

                if (!feaLayer.showInLegend)
                {
                    layerXML.@showinlegend = false;
                }
            }
        }
        else if (layer is GeoRSSLayer)
        {
            var geoRSSLayer:GeoRSSLayer = layer as GeoRSSLayer;

            layerXML = <layer label={label}
                    type="georss"
                    visible={geoRSSLayer.visible}
                    alpha={geoRSSLayer.alpha}
                    url={geoRSSLayer.url}/>;

            if (geoRSSLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(geoRSSLayer.refreshInterval);
            }

            if (!geoRSSLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }

            if (geoRSSLayer.serviceURL)
            {
                layerXML.@serviceurl = geoRSSLayer.serviceURL;
            }

            if (geoRSSLayer.pointSymbol)
            {
                layerXML.appendChild(getPointSymbolXML(geoRSSLayer.pointSymbol));
            }

            if (geoRSSLayer.polylineSymbol)
            {
                layerXML.appendChild(getLineSymbolXML(geoRSSLayer.polylineSymbol));
            }

            if (geoRSSLayer.polygonSymbol)
            {
                layerXML.appendChild(getPolygonSymbolXML(geoRSSLayer.polygonSymbol));
            }
        }
        else if (layer is KMLLayer)
        {
            var kmlLayer:KMLLayer = layer as KMLLayer;

            layerXML = <layer label={label}
                    type="kml"
                    visible={kmlLayer.visible}
                    alpha={kmlLayer.alpha}
                    url={kmlLayer.url}/>;

            if (kmlLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(kmlLayer.refreshInterval);
            }

            if (!kmlLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }
        }
        else if (layer is OpenStreetMapLayer)
        {
            var osmLayer:OpenStreetMapLayer = layer as OpenStreetMapLayer;

            layerXML = <layer label={label}
                    type="osm"
                    visible={osmLayer.visible}
                    alpha={osmLayer.alpha}/>;

            if (osmLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(osmLayer.refreshInterval);
            }

            if (!osmLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }
        }
        else if (layer is VETiledLayer)
        {
            var veLayer:VETiledLayer = layer as VETiledLayer;

            layerXML = <layer label={label}
                    type="bing"
                    visible={veLayer.visible}
                    alpha={veLayer.alpha}
                    style={veLayer.mapStyle}/>;

            if (veLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(veLayer.refreshInterval);
            }

            if (!veLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }

            if (veLayer.displayLevels)
            {
                layerXML.@displaylevels = veLayer.displayLevels.join();
            }
        }
        else if (layer is WMSLayer)
        {
            var wmsLayer:WMSLayer = layer as WMSLayer;

            layerXML = <layer label={label}
                    type="wms"
                    visible={wmsLayer.visible}
                    alpha={wmsLayer.alpha}
                    version={wmsLayer.version}
                    skipgetcapabilities={wmsLayer.skipGetCapabilities}
                    imageformat={wmsLayer.imageFormat}
                    url={wmsLayer.url}/>;

            if (wmsLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(wmsLayer.refreshInterval);
            }

            if (!wmsLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }

            if (wmsLayer.copyright)
            {
                layerXML.@copyright = wmsLayer.copyright;
            }

            if (wmsLayer.spatialReference)
            {
                layerXML.@wkid = wmsLayer.spatialReference.wkid;
            }

            if (wmsLayer.maxImageHeight > 0)
            {
                layerXML.@maximageheight = wmsLayer.maxImageHeight;
            }

            if (wmsLayer.maxImageWidth > 0)
            {
                layerXML.@maximagewidth = wmsLayer.maxImageWidth;
            }

            if (wmsLayer.visibleLayers)
            {
                layerXML.@visiblelayers = wmsLayer.visibleLayers.toArray().join();
            }
        }
        else if (layer is WMTSLayer)
        {
            var wmtsLayer:WMTSLayer = layer as WMTSLayer;

            layerXML = <layer label={label}
                    type="wmts"
                    visible={wmtsLayer.visible}
                    alpha={wmtsLayer.alpha}
                    version={wmtsLayer.version}
                    imageformat={wmtsLayer.imageFormat}
                    url={wmtsLayer.url}
                    useproxy={wmtsLayer.proxyURL != null}/>;

            if (wmtsLayer.refreshInterval > 0)
            {
                layerXML.@autorefresh = minutesToSeconds(wmtsLayer.refreshInterval);
            }

            if (!wmtsLayer.showInLegend)
            {
                layerXML.@showinlegend = false;
            }

            if (wmtsLayer.layerId)
            {
                layerXML.@layerid = wmtsLayer.layerId;
            }

            if (wmtsLayer.serviceMode)
            {
                layerXML.@mode = wmtsLayer.serviceMode;
            }

            if (wmtsLayer.style)
            {
                layerXML.@style = wmtsLayer.style;
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
                layerXML = <layer label={label}
                        type="webtiled"
                        visible={webTiledLayer.visible}
                        alpha={webTiledLayer.alpha}
                        url={webTiledLayer.urlTemplate}/>;

                if (webTiledLayer.refreshInterval > 0)
                {
                    layerXML.@autorefresh = minutesToSeconds(webTiledLayer.refreshInterval);
                }

                if (!webTiledLayer.showInLegend)
                {
                    layerXML.@showinlegend = false;
                }

                if (webTiledLayer.copyright)
                {
                    layerXML.@copyright = webTiledLayer.copyright;
                }

                if (webTiledLayer.displayLevels)
                {
                    layerXML.@displaylevels = webTiledLayer.displayLevels.join();
                }

                if (webTiledLayer.subDomains)
                {
                    layerXML.@subdomains = webTiledLayer.subDomains.join();
                }
            }
        }

        return layerXML;
    }

    private static function minutesToSeconds(minutes:Number):Number
    {
        const SECONDS_IN_MINUTE:int = 60;
        return minutes * SECONDS_IN_MINUTE;
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
}
}
