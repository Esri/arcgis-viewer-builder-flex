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
package modules.Geoprocessing.supportClasses
{

import com.esri.ags.portal.supportClasses.PopUpFieldFormat;
import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.ags.portal.supportClasses.PopUpInfo;
import com.esri.ags.portal.supportClasses.PopUpMediaInfo;
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
import com.esri.builder.supportClasses.FieldUtil;

import modules.Geoprocessing.parameters.FeatureLayerParameter;
import modules.Geoprocessing.parameters.GPParameterFactory;
import modules.Geoprocessing.parameters.IGPFeatureParameter;
import modules.Geoprocessing.parameters.IGPParameter;

public class GPParamParser
{
    public function parseParameters(paramsXMLList:XMLList):Array
    {
        var parameters:Array = [];
        var param:IGPParameter;

        for each (var paramXML:XML in paramsXMLList)
        {
            param = GPParameterFactory.getGPParamFromType(paramXML.@type);
            param.defaultValueFromString(String(paramXML.@defaultvalue));

            param.label = paramXML.@label;
            param.name = paramXML.@name;
            param.toolTip = paramXML.@tooltip;
            param.visible = (paramXML.@visible == "true");
            param.required = (paramXML.@required == "true");

            if (paramXML.choicelist[0])
            {
                param.choiceList = parseChoiceList(paramXML.choicelist.choice);
            }

            var featureParam:IGPFeatureParameter = param as IGPFeatureParameter;
            if (featureParam)
            {
                featureParam.geometryType = paramXML.@geometrytype;
                featureParam.mode = paramXML.@mode || FeatureLayerParameter.DRAW_SOURCE;
                featureParam.layerName = featureParam.label;

                if (paramXML.popup[0])
                {
                    featureParam.popUpInfo = parsePopUpInfo(paramXML.popup[0]);
                }

                if (featureParam.geometryType)
                {
                    if (paramXML.renderer[0])
                    {
                        featureParam.renderer = parseRenderer(paramXML.renderer[0]);
                    }
                    else
                    {
                        featureParam.renderer = new SimpleRenderer(createDefaultSymbolFromGeometry(featureParam.geometryType));
                    }
                }
            }

            parameters.push(param);
        }

        return parameters;
    }

    private function createDefaultSymbolFromGeometry(geometryType:String):Symbol
    {
        var defaultSymbol:Symbol;
        var defaultColor:uint = 0x3FAFDC;
        var defaultAlpha:Number = 1;

        if (geometryType == FeatureLayerParameter.POINT)
        {
            defaultSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 15, defaultColor, defaultAlpha, 0, 0, 0, new SimpleLineSymbol());
        }
        else if (geometryType == FeatureLayerParameter.POLYGON)
        {
            defaultSymbol = new SimpleFillSymbol(SimpleFillSymbol.STYLE_SOLID, defaultColor, defaultAlpha, new SimpleLineSymbol());
        }
        else if (geometryType == FeatureLayerParameter.POLYLINE)
        {
            defaultSymbol = createOutlineSymbol(defaultColor, defaultAlpha, 5);
        }

        return defaultSymbol;
    }

    private function parseChoiceList(choiceListXML:XMLList):Array
    {
        var choiceList:Array = [];
        var choiceValue:String;

        for each (var choice:XML in choiceListXML)
        {
            choiceValue = choice.@value;
            choiceList.push(choiceValue);
        }

        return choiceList;
    }

    private function parsePopUpInfo(popUpXML:XML):PopUpInfo
    {
        var popUpInfo:PopUpInfo = new PopUpInfo();

        if (popUpXML.title[0])
        {
            popUpInfo.title = popUpXML.title;
        }

        if (popUpXML.description[0])
        {
            popUpInfo.description = popUpXML.description;
        }

        if (popUpXML.fields[0])
        {
            popUpInfo.popUpFieldInfos = parsePopUpFields(popUpXML.fields[0]);
        }

        if (popUpXML.medias[0])
        {
            popUpInfo.popUpMediaInfos = parsePopUpMedias(popUpXML.medias[0]);
        }

        if (popUpXML.showattachments[0])
        {
            popUpInfo.showAttachments = (popUpXML.showattachments == "true");
        }

        if (popUpXML.showrelatedrecords[0])
        {
            popUpInfo.showRelatedRecords = (popUpXML.showrelatedrecords == "true");
        }

        return popUpInfo;
    }

    private function parsePopUpFields(fieldsXML:XML):Array
    {
        var fields:Array = [];
        var field:PopUpFieldInfo;

        for each (var fieldXML:XML in fieldsXML.field)
        {
            if (!FieldUtil.isValidFieldName(fieldXML.@name[0]))
            {
                continue;
            }

            field = new PopUpFieldInfo();
            field.label = fieldXML.@label;
            field.fieldName = fieldXML.@name;
            field.visible = fieldXML.@visible == "true";
            if (fieldXML.format[0])
            {
                field.format = parsePopUpFieldFormat(fieldXML.format[0]);
            }

            fields.push(field);
        }

        return fields;
    }

    private function parsePopUpFieldFormat(formatXML:XML):PopUpFieldFormat
    {
        var popUpFieldFormat:PopUpFieldFormat = new PopUpFieldFormat();

        if (formatXML.@dateformat[0])
        {
            popUpFieldFormat.dateFormat = formatXML.@dateformat;
        }
        popUpFieldFormat.precision = formatXML.@precision[0] ? formatXML.@precision : -1;
        popUpFieldFormat.useThousandsSeparator = (formatXML.@usethousandsseparator == "true");

        return popUpFieldFormat;
    }

    private function parsePopUpMedias(mediasXML:XML):Array
    {
        var medias:Array = [];
        var media:PopUpMediaInfo;

        for each (var mediaXML:XML in mediasXML.media)
        {
            media = new PopUpMediaInfo();

            media.caption = mediaXML.@caption;
            if (mediaXML.@chartfields[0])
            {
                media.chartFields = mediaXML.@chartfields.split(',');
            }
            media.chartNormalizationField = mediaXML.@chartnormalizationfield;
            media.imageLinkURL = mediaXML.@imagelinkurl;
            media.imageSourceURL = mediaXML.@imagesourceurl;
            media.title = mediaXML.@title;
            media.type = mapMediaType(mediaXML.@type);

            medias.push(media);
        }

        return medias;
    }

    private function mapMediaType(type:String):String
    {
        var mediaType:String;

        switch (type)
        {
            case "image":
            {
                mediaType = PopUpMediaInfo.IMAGE;
                break;
            }
            case "barchart":
            {
                mediaType = PopUpMediaInfo.BAR_CHART;
                break;
            }
            case "columnchart":
            {
                mediaType = PopUpMediaInfo.COLUMN_CHART;
                break;
            }
            case "linechart":
            {
                mediaType = PopUpMediaInfo.LINE_CHART;
                break;
            }
            case "piechart":
            {
                mediaType = PopUpMediaInfo.PIE_CHART;
                break;
            }
        }

        return mediaType;
    }

    private function parseRenderer(rendererXML:XML):IRenderer
    {
        var renderer:IRenderer;
        var rendererSymbol:Symbol;
        var rendererInfos:Array;

        if (rendererXML.defaultsymbol[0])
        {
            rendererSymbol = parseSymbol(rendererXML.defaultsymbol[0]);
        }
        else
        {
            rendererSymbol = new SimpleFillSymbol();
        }

        if (rendererXML.@type == FeatureLayerParameter.SIMPLE_RENDERER)
        {
            renderer = new SimpleRenderer(rendererSymbol);
        }
        else if (rendererXML.@type == FeatureLayerParameter.CLASS_BREAKS_RENDERER)
        {
            rendererInfos = parseClassBreakInfos(rendererXML.infos.symbol);
            renderer = new ClassBreaksRenderer(rendererXML.@attribute, rendererSymbol, rendererInfos);
        }
        else if (rendererXML.@type == FeatureLayerParameter.UNIQUE_VALUE_RENDERER)
        {
            rendererInfos = parseUniqueValueInfos(rendererXML.infos.symbol);
            renderer = new UniqueValueRenderer(rendererXML.@attribute, rendererSymbol, rendererInfos);
        }

        return renderer;
    }

    private function parseUniqueValueInfos(uniqueValueInfosXMLList:XMLList):Array
    {
        var uniqueValueInfos:Array = [];

        for each (var uniqueValueInfoXML:XML in uniqueValueInfosXMLList)
        {
            uniqueValueInfos.push(
                new UniqueValueInfo(parseSymbol(uniqueValueInfoXML[0]), uniqueValueInfoXML.@value));
        }

        return uniqueValueInfos;
    }

    private function parseClassBreakInfos(classBreaksInfosXMLList:XMLList):Array
    {
        var classBreakInfos:Array = [];

        for each (var classBreaksInfoXML:XML in classBreaksInfosXMLList)
        {
            classBreakInfos.push(
                new ClassBreakInfo(parseSymbol(classBreaksInfoXML[0]), classBreaksInfoXML.@min, classBreaksInfoXML.@max));
        }

        return classBreakInfos;
    }

    private function parseSymbol(symbolXML:XML):Symbol
    {
        var symbol:Symbol;
        var type:String = symbolXML.@type;

        if (type == FeatureLayerParameter.SIMPLE_MARKER)
        {
            symbol = parseSimpleMarkerSymbol(symbolXML);
        }
        else if (type == FeatureLayerParameter.SIMPLE_FILL)
        {
            symbol = parseSimpleFillSymbol(symbolXML);
        }
        else if (type == FeatureLayerParameter.SIMPLE_LINE)
        {
            symbol = parseSimpleLineSymbol(symbolXML);
        }
        else if (type == FeatureLayerParameter.PICTURE_MARKER)
        {
            symbol = parsePictureMarkerSymbol(symbolXML);
        }

        return symbol;
    }

    private function parseSimpleMarkerSymbol(symbolXML:XML):SimpleMarkerSymbol
    {
        const parsedColor:Number = parseInt(symbolXML.@color[0]);
        const parsedAlpha:Number = parseFloat(symbolXML.@alpha[0]);
        const parsedSize:Number = parseFloat(symbolXML.@size[0]);
        const parsedOutlineColor:uint = parseInt(symbolXML.outline.@color[0]);
        const parsedOutlineWidth:Number = parseFloat(symbolXML.outline.@width[0]);

        const color:uint = !isNaN(parsedColor) ? parsedColor : 0xFFFFFF;
        const alpha:Number = !isNaN(parsedAlpha) ? parsedAlpha : 0.5;
        const size:Number = !isNaN(parsedSize) ? parsedSize : 20;
        const outlineColor:uint = !isNaN(parsedOutlineColor) ? parsedOutlineColor : 0x000000;
        const outlineWidth:Number = !isNaN(parsedOutlineWidth) ? parsedOutlineWidth : 1;

        return new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, size, color, alpha, 0, 0, 0, createOutlineSymbol(outlineColor, alpha, outlineWidth));
    }

    private function parseSimpleFillSymbol(symbolXML:XML):SimpleFillSymbol
    {
        const parsedColor:Number = parseInt(symbolXML.@color[0]);
        const parsedAlpha:Number = parseFloat(symbolXML.@alpha[0]);
        const parsedOutlineColor:uint = parseInt(symbolXML.outline.@color[0]);
        const parsedOutlineWidth:Number = parseFloat(symbolXML.outline.@width[0]);

        const color:uint = !isNaN(parsedColor) ? parsedColor : 0xFFFFFF;
        const alpha:Number = !isNaN(parsedAlpha) ? parsedAlpha : 0.5;
        const outlineColor:uint = !isNaN(parsedOutlineColor) ? parsedOutlineColor : 0x000000;
        const outlineWidth:Number = !isNaN(parsedOutlineWidth) ? parsedOutlineWidth : 2;

        return new SimpleFillSymbol(SimpleFillSymbol.STYLE_SOLID, color, alpha, createOutlineSymbol(outlineColor, alpha, outlineWidth));
    }

    private function parseSimpleLineSymbol(symbolXML:XML):SimpleLineSymbol
    {
        const parsedAlpha:Number = parseFloat(symbolXML.@alpha[0]);
        const parsedOutlineColor:uint = parseInt(symbolXML.outline.@color[0]);
        const parsedOutlineWidth:Number = parseFloat(symbolXML.outline.@width[0]);

        const alpha:Number = !isNaN(parsedAlpha) ? parsedAlpha : 0.5;
        const outlineColor:uint = !isNaN(parsedOutlineColor) ? parsedOutlineColor : 0x000000;
        const outlineWidth:Number = !isNaN(parsedOutlineWidth) ? parsedOutlineWidth : 5;

        return createOutlineSymbol(outlineColor, alpha, outlineWidth);
    }

    private function createOutlineSymbol(color:uint, alpha:Number, width:Number):SimpleLineSymbol
    {
        return new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, color, alpha, width);
    }

    private function parsePictureMarkerSymbol(symbolXML:XML):PictureMarkerSymbol
    {
        const url:String = symbolXML.@url;

        const parsedHeight:Number = parseFloat(symbolXML.@height[0]);
        const parsedWidth:Number = parseFloat(symbolXML.@width[0]);
        const parsedXOffset:Number = parseFloat(symbolXML.@xoffset[0]);
        const parsedYOffset:Number = parseFloat(symbolXML.@yoffset[0]);
        const parsedAngle:Number = parseFloat(symbolXML.@angle[0]);

        const height:Number = !isNaN(parsedHeight) ? parsedHeight : 0;
        const width:Number = !isNaN(parsedWidth) ? parsedWidth : 0;
        const xOffset:Number = !isNaN(parsedXOffset) ? parsedXOffset : 0;
        const yOffset:Number = !isNaN(parsedYOffset) ? parsedYOffset : 0;
        const angle:Number = !isNaN(parsedAngle) ? parsedAngle : 0;

        return new PictureMarkerSymbol(url, width, height, xOffset, yOffset, angle);
    }
}

}
