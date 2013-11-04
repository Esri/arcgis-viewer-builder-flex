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
            if (dynLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(dynLyr.refreshInterval);
            }
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
            if (imgLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(imgLyr.refreshInterval);
            }
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
            if (tiledLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(tiledLyr.refreshInterval);
            }
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
            if (csvLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(csvLyr.refreshInterval);
            }
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
                if (feaLyr.refreshInterval > 0)
                {
                    lyrXML.@autorefresh = minutesToSeconds(feaLyr.refreshInterval);
                }
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
            if (geoRSSLayer.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(geoRSSLayer.refreshInterval);
            }
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
            if (kmlLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(kmlLyr.refreshInterval);
            }
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
            if (osmLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(osmLyr.refreshInterval);
            }
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
            if (veLyr.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(veLyr.refreshInterval);
            }
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
            if (wmsLayer.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(wmsLayer.refreshInterval);
            }
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
                    useproxy={wmtsLayer.proxyURL != null}/>;
            if (wmtsLayer.refreshInterval > 0)
            {
                lyrXML.@autorefresh = minutesToSeconds(wmtsLayer.refreshInterval);
            }
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
                if (webTiledLayer.refreshInterval > 0)
                {
                    lyrXML.@autorefresh = minutesToSeconds(webTiledLayer.refreshInterval);
                }
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
