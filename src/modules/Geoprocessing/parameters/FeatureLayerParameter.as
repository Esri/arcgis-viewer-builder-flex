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
package modules.Geoprocessing.parameters
{

import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.renderers.ClassBreaksRenderer;
import com.esri.ags.renderers.IRenderer;
import com.esri.ags.renderers.SimpleRenderer;
import com.esri.ags.renderers.UniqueValueRenderer;
import com.esri.ags.renderers.supportClasses.ClassBreakInfo;
import com.esri.ags.renderers.supportClasses.UniqueValueInfo;
import com.esri.ags.symbols.PictureMarkerSymbol;
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.symbols.Symbol;
import com.esri.ags.portal.PopUpRenderer;
import com.esri.ags.portal.supportClasses.PopUpFieldFormat;
import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.ags.portal.supportClasses.PopUpInfo;
import com.esri.ags.portal.supportClasses.PopUpMediaInfo;

import modules.Geoprocessing.paramEditor.input.InputFeatureLayerParamEditor;
import modules.Geoprocessing.paramEditor.output.OutputFeatureLayerParamEditor;

import mx.core.ClassFactory;
import mx.core.IVisualElement;

[Bindable]
public class FeatureLayerParameter extends BaseParameter implements IGPFeatureParameter
{
    public static const DRAW_SOURCE:String = "drawtool";
    public static const LAYERS_SOURCE:String = "layers";

    public static const POINT:String = "point";
    public static const POLYGON:String = "polygon";
    public static const POLYLINE:String = "polyline";

    public static const SIMPLE_MARKER:String = "simplemarker";
    public static const SIMPLE_FILL:String = "simplefill";
    public static const SIMPLE_LINE:String = "simpleline";
    public static const PICTURE_MARKER:String = "picturemarker";

    public static const SIMPLE_RENDERER:String = "simple";
    public static const CLASS_BREAKS_RENDERER:String = "classbreaks";
    public static const UNIQUE_VALUE_RENDERER:String = "uniquevalue";

    public function FeatureLayerParameter()
    {
        _layer = new GraphicsLayer();
    }

    private var _geometryType:String;

    public function get geometryType():String
    {
        return _geometryType;
    }

    public function set geometryType(value:String):void
    {
        _geometryType = value;
    }

    private var _mode:String;

    public function get mode():String
    {
        return _mode;
    }

    public function set mode(value:String):void
    {
        _mode = value;
    }

    private var _popUpInfo:PopUpInfo;

    public function get popUpInfo():PopUpInfo
    {
        return _popUpInfo;
    }

    public function set popUpInfo(value:PopUpInfo):void
    {
        _popUpInfo = value;
    }

    private var _layer:GraphicsLayer;

    public function get layer():GraphicsLayer
    {
        return _layer;
    }

    private var _renderer:IRenderer;

    public function get renderer():IRenderer
    {
        return _renderer;
    }

    public function set renderer(value:IRenderer):void
    {
        _renderer = value;
        _layer.renderer = value;
    }

    private var _layerName:String;

    public function get layerName():String
    {
        return _layerName;
    }

    public function set layerName(value:String):void
    {
        _layerName = value;
        _layer.name = value;
    }

    public function get popUpRenderer():ClassFactory
    {
        var popUpRenderer:ClassFactory = new ClassFactory(PopUpRenderer);
        var popUpInfo:PopUpInfo = _popUpInfo;
        popUpRenderer.properties = { popUpInfo: popUpInfo };
        return popUpRenderer;
    }

    public function get defaultSymbol():Symbol
    {
        var symbol:Symbol;

        if (_renderer is SimpleRenderer)
        {
            symbol = (_renderer as SimpleRenderer).symbol;
        }
        else if (_renderer is ClassBreaksRenderer)
        {
            symbol = (_renderer as ClassBreaksRenderer).defaultSymbol;
        }
        else if (_renderer is UniqueValueRenderer)
        {
            symbol = (_renderer as UniqueValueRenderer).defaultSymbol;
        }

        return symbol;
    }

    private function getPopUpInfoXML():XML
    {
        var popUpInfoXML:XML = <popup></popup>;
        if (popUpInfo.title)
        {
            popUpInfoXML.appendChild(getPopUpTitleXML());
        }

        if (popUpInfo.description)
        {
            popUpInfoXML.appendChild(getPopUpDescriptionXML());
        }

        popUpInfoXML.appendChild(getPopUpFieldsXML());
        popUpInfoXML.appendChild(getPopUpMediasXML());
        popUpInfoXML.appendChild(getPopUpShowAttachmentsXML());
        popUpInfoXML.appendChild(getPopUpShowRelatedRecordsXML());

        return popUpInfoXML;
    }

    private function getPopUpShowAttachmentsXML():XML
    {
        var showAttachmentsXML:XML = <showattachments>{popUpInfo.showAttachments}</showattachments>;
        return showAttachmentsXML;
    }

    private function getPopUpShowRelatedRecordsXML():XML
    {
        var showRelatedRecordsXML:XML = <showrelatedrecords>{popUpInfo.showRelatedRecords}</showrelatedrecords>;
        return showRelatedRecordsXML;
    }

    private function getPopUpMediasXML():XML
    {
        var mediasXML:XML = <medias></medias>;
        var mediaXML:XML;

        for each (var media:PopUpMediaInfo in popUpInfo.popUpMediaInfos)
        {
            mediaXML = <media/>;
            mediaXML.@caption = media.caption;
            mediaXML.@chartfields = media.chartFields;
            mediaXML.@imagelinkurl = media.imageLinkURL;
            mediaXML.@imagesourceurl = media.imageSourceURL;
            mediaXML.@title = media.title;
            mediaXML.@type = media.type;

            mediasXML.appendChild(mediaXML);
        }

        return mediasXML;
    }

    private function getPopUpDescriptionXML():XML
    {
        var descriptionXML:XML = <description>{popUpInfo.description}</description>;
        return descriptionXML;
    }

    private function getPopUpTitleXML():XML
    {
        var fieldTitleXML:XML = <title>{popUpInfo.title}</title>;
        return fieldTitleXML;
    }

    private function getPopUpFieldsXML():XML
    {
        var fieldsXML:XML = <fields></fields>;
        var fieldXML:XML;

        for each (var field:PopUpFieldInfo in popUpInfo.popUpFieldInfos)
        {
            fieldXML = <field/>;
            fieldXML.@name = field.fieldName;
            if (field.format)
            {
                fieldXML.@format = getFieldFormatXML(field.format);
            }
            fieldXML.@label = field.label;
            fieldXML.@visible = field.visible;

            fieldsXML.appendChild(fieldXML);
        }

        return fieldsXML;
    }

    private function getFieldFormatXML(format:PopUpFieldFormat):XML
    {
        var formatXML:XML = <format></format>;
        formatXML.@dateformat = format.dateFormat;
        formatXML.@precision = format.precision;
        formatXML.@usethousandsseparator = format.useThousandsSeparator;
        return formatXML;
    }

    private function getRendererXML():XML
    {
        var rendererXML:XML = <renderer></renderer>;

        if (renderer is SimpleRenderer)
        {
            rendererXML.@type = SIMPLE_RENDERER;
        }
        else if (renderer is ClassBreaksRenderer)
        {
            var classBreaksRenderer:ClassBreaksRenderer = renderer as ClassBreaksRenderer;
            rendererXML.@type = CLASS_BREAKS_RENDERER;
            rendererXML.@attribute = classBreaksRenderer.field;
            rendererXML.appendChild(parseClassBreaksInfos(classBreaksRenderer.infos));
        }
        else if (renderer is UniqueValueRenderer)
        {
            var uniqueValueRenderer:UniqueValueRenderer = renderer as UniqueValueRenderer;
            rendererXML.@type = UNIQUE_VALUE_RENDERER;
            rendererXML.@attribute = uniqueValueRenderer.field;
            rendererXML.appendChild(parseUniqueValueInfos(uniqueValueRenderer.infos));
        }

        rendererXML.appendChild(getRendererSymbolXML());

        return rendererXML;
    }

    private function parseClassBreaksInfos(infos:Array):XML
    {
        var infosXML:XML = <infos/>;
        var symbolXML:XML;
        for each (var classBreakInfo:ClassBreakInfo in infos)
        {
            symbolXML = <symbol/>;
            symbolXML.@min = classBreakInfo.minValue;
            symbolXML.@max = classBreakInfo.maxValue;
            setSymbolXMLProperties(symbolXML, classBreakInfo.symbol);
            infosXML.appendChild(symbolXML);
        }
        return infosXML;
    }

    private function parseUniqueValueInfos(infos:Array):XML
    {
        var infosXML:XML = <infos/>;
        var symbolXML:XML;
        for each (var uniqueValueInfo:UniqueValueInfo in infos)
        {
            symbolXML = <symbol/>;
            symbolXML.@value = uniqueValueInfo.value;
            setSymbolXMLProperties(symbolXML, uniqueValueInfo.symbol);
            infosXML.appendChild(symbolXML);
        }
        return infosXML;
    }

    private function getRendererSymbolXML():XML
    {
        var rendererSymbolXML:XML;
        var rendererSymbol:Symbol;
        if (renderer is SimpleRenderer)
        {
            rendererSymbol = (renderer as SimpleRenderer).symbol;
        }
        else if (renderer is ClassBreaksRenderer)
        {
            rendererSymbol = (renderer as ClassBreaksRenderer).defaultSymbol;
        }
        else if (renderer is UniqueValueRenderer)
        {
            rendererSymbol = (renderer as UniqueValueRenderer).defaultSymbol;
        }

        rendererSymbolXML = getSymbolXML(rendererSymbol);
        return rendererSymbolXML;
    }

    private function getSymbolXML(symbol:Symbol):XML
    {
        var symbolXML:XML = <defaultsymbol/>;
        setSymbolXMLProperties(symbolXML, symbol);
        return symbolXML;
    }

    private function setSymbolXMLProperties(symbolXML:XML, symbol:Symbol):void
    {
        if (symbol is SimpleMarkerSymbol)
        {
            setSimpleMarkerSymbolXMLProperties(symbolXML, symbol as SimpleMarkerSymbol);
        }
        else if (symbol is SimpleFillSymbol)
        {
            setSimpleFillSymbolXMLProperties(symbolXML, symbol as SimpleFillSymbol);
        }
        else if (symbol is SimpleLineSymbol)
        {
            setSimpleLineSymbolXMLProperties(symbolXML, symbol as SimpleLineSymbol);
        }
        else if (symbol is PictureMarkerSymbol)
        {
            setPictureMarkerSymbolXMLProperties(symbolXML, symbol as PictureMarkerSymbol);
        }
    }

    private function setSimpleMarkerSymbolXMLProperties(symbolXML:XML, simpleMarkerSymbol:SimpleMarkerSymbol):void
    {
        symbolXML.@type = SIMPLE_MARKER;
        symbolXML.@alpha = simpleMarkerSymbol.alpha;
        symbolXML.@color = formatColorValue(simpleMarkerSymbol.color);
        symbolXML.@size = simpleMarkerSymbol.size;
        symbolXML.appendChild(getSymbolOutlineXML(simpleMarkerSymbol.outline));
    }

    private function setPictureMarkerSymbolXMLProperties(symbolXML:XML, pictureMarkerSymbol:PictureMarkerSymbol):void
    {
        symbolXML.@type = PICTURE_MARKER;
        symbolXML.@url = pictureMarkerSymbol.source;
        symbolXML.@height = pictureMarkerSymbol.height;
        symbolXML.@width = pictureMarkerSymbol.width;
        symbolXML.@xoffset = pictureMarkerSymbol.xoffset;
        symbolXML.@yoffset = pictureMarkerSymbol.yoffset;
        symbolXML.@angle = pictureMarkerSymbol.angle;
    }

    private function setSimpleFillSymbolXMLProperties(symbolXML:XML, simpleFillSymbol:SimpleFillSymbol):void
    {
        symbolXML.@type = SIMPLE_FILL;
        symbolXML.@alpha = simpleFillSymbol.alpha;
        symbolXML.@color = formatColorValue(simpleFillSymbol.color);
        symbolXML.appendChild(getSymbolOutlineXML(simpleFillSymbol.outline));
    }

    private function setSimpleLineSymbolXMLProperties(symbolXML:XML, simpleLineSymbol:SimpleLineSymbol):void
    {
        symbolXML.@type = SIMPLE_LINE;
        symbolXML.@alpha = simpleLineSymbol.alpha;
        symbolXML.appendChild(getSymbolOutlineXML(simpleLineSymbol));
    }

    private function getSymbolOutlineXML(outlineSymbol:SimpleLineSymbol):XML
    {
        var outlineXML:XML = <outline></outline>;

        outlineXML.@color = formatColorValue(outlineSymbol.color);
        outlineXML.@width = outlineSymbol.width;

        return outlineXML;
    }

    private function formatColorValue(color:uint):String
    {
        var hexColor:String = color.toString(16);
        hexColor = hexColor.toUpperCase();
        hexColor = addZeroPadding(hexColor);
        return "0x" + hexColor;
    }

    private function addZeroPadding(hexColor:String):String
    {
        var leadingZeroes:String = "";

        for (var i:int = hexColor.length; i < 6; i++)
        {
            leadingZeroes += "0";
        }

        return leadingZeroes + hexColor;
    }

    override public function get type():String
    {
        return GPParameterTypes.FEATURE_RECORD_SET_LAYER;
    }

    override public function set name(value:String):void
    {
        super.name = value;
        _layer.id = value;
    }

    override public function toXML():XML
    {
        var paramXML:XML = <param/>

        paramXML.@type = type;
        paramXML.@name = name;
        if (geometryType)
        {
            paramXML.@geometrytype = geometryType;
        }
        paramXML.@mode = mode;
        paramXML.@required = required;
        paramXML.@visible = visible;

        if (label)
        {
            paramXML.@label = label;
        }

        if (toolTip)
        {
            paramXML.@tooltip = toolTip;
        }

        if (popUpInfo)
        {
            paramXML.appendChild(getPopUpInfoXML());
        }

        if (renderer)
        {
            paramXML.appendChild(getRendererXML());
        }

        return paramXML;
    }

    override public function createInputEditorView():IVisualElement
    {
        var editorView:InputFeatureLayerParamEditor = new InputFeatureLayerParamEditor();
        editorView.param = this;
        return editorView;
    }

    override public function createOutputEditorView():IVisualElement
    {
        var editorView:OutputFeatureLayerParamEditor = new OutputFeatureLayerParamEditor();
        editorView.param = this;
        return editorView;
    }
}

}
