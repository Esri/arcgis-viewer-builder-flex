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

import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.ags.portal.supportClasses.PopUpInfo;
import com.esri.ags.renderers.IRenderer;
import com.esri.ags.renderers.SimpleRenderer;
import com.esri.ags.symbols.SimpleFillSymbol;
import com.esri.ags.symbols.SimpleLineSymbol;
import com.esri.ags.symbols.SimpleMarkerSymbol;
import com.esri.ags.symbols.Symbol;
import com.esri.builder.supportClasses.FieldUtil;

import modules.Geoprocessing.parameters.FeatureLayerParameter;
import modules.Geoprocessing.parameters.GPParameterFactory;
import modules.Geoprocessing.parameters.GPParameterTypes;
import modules.Geoprocessing.parameters.IGPFeatureParameter;
import modules.Geoprocessing.parameters.IGPParameter;

public class ServiceDescriptionParamParser
{
    private const REQUIRED:String = "esriGPParameterTypeRequired";
    private const INPUT:String = "esriGPParameterDirectionInput";
    private const OUTPUT:String = "esriGPParameterDirectionOutput";

    private const ESRI_GEOMETRY_POINT:String = "esriGeometryPoint";
    private const ESRI_GEOMETRY_POLYGON:String = "esriGeometryPolygon";
    private const ESRI_GEOMETRY_POLYLINE:String = "esriGeometryPolyline";

    private var _inputParams:Array;

    public function get inputParams():Array
    {
        return _inputParams;
    }

    private var _outputParams:Array;

    public function get outputParams():Array
    {
        return _outputParams;
    }

    private var _layerOrder:Array;

    public function get layerOrder():Array
    {
        return _layerOrder;
    }

    public function ServiceDescriptionParamParser(serviceParams:Array)
    {
        _inputParams = [];
        _outputParams = [];
        _layerOrder = [];

        parseParams(serviceParams);
    }

    private function parseParams(serviceParams:Array):void
    {
        var param:IGPParameter;

        for each (var serviceParam:Object in serviceParams)
        {
            //ONLY MULTIVALUE:STRING SUPPORTED
            param = GPParameterFactory.getGPParamFromType(GPParameterTypes.toPrettyDataType(serviceParam.dataType));
            param.defaultValue = serviceParam.defaultValue;
            param.label = serviceParam.displayName;
            param.name = serviceParam.name;
            param.toolTip = "";
            param.required = (serviceParam.parameterType == REQUIRED);
            param.choiceList = serviceParam.choicelist || serviceParam.choiceList;

            var featureParam:IGPFeatureParameter = param as IGPFeatureParameter;
            if (featureParam)
            {
                featureParam.geometryType = mapGeometryType(featureParam.defaultValue.geometryType);
                featureParam.mode = FeatureLayerParameter.DRAW_SOURCE;
                if (serviceParam.direction == OUTPUT)
                {
                    if (serviceParam.defaultValue.fields)
                    {
                        featureParam.popUpInfo = parsePopUpFields(serviceParam.defaultValue.fields);
                    }

                    if (featureParam.geometryType)
                    {
                        featureParam.renderer = createParameterRenderer(0x000000, 0.5, 0x000000, 2, featureParam.geometryType);
                    }
                }
                else if (featureParam.geometryType)
                {
                    featureParam.renderer = createParameterRenderer(0x3FAFDC, 1, 0x000000, 2, featureParam.geometryType);
                }

                featureParam.layerName = featureParam.label;
                _layerOrder.push(featureParam.name);
            }

            if (serviceParam.direction == INPUT)
            {
                _inputParams.push(param);
            }
            else if (serviceParam.direction == OUTPUT)
            {
                _outputParams.push(param);
            }
        }
    }

    private function mapGeometryType(esriGeometryType:String):String
    {
        var prettyGeometryType:String;

        switch (esriGeometryType)
        {
            case ESRI_GEOMETRY_POINT:
            {
                prettyGeometryType = FeatureLayerParameter.POINT;
                break;
            }
            case ESRI_GEOMETRY_POLYGON:
            {
                prettyGeometryType = FeatureLayerParameter.POLYGON;
                break;
            }
            case ESRI_GEOMETRY_POLYLINE:
            {
                prettyGeometryType = FeatureLayerParameter.POLYLINE;
                break;
            }
        }

        return prettyGeometryType;
    }

    private function parsePopUpFields(fieldsObject:Object):PopUpInfo
    {
        var fieldsInfo:PopUpInfo = new PopUpInfo();
        var fields:Array = [];
        var field:PopUpFieldInfo;

        for each (var fieldObject:Object in fieldsObject)
        {
            if (!FieldUtil.isValidFieldName(fieldObject.name))
            {
                continue;
            }

            field = new PopUpFieldInfo();
            field.fieldName = fieldObject.name;
            field.label = fieldObject.alias ? fieldObject.alias : "";
            field.visible = true;

            fields.push(field);
        }

        fieldsInfo.popUpFieldInfos = fields;

        return fieldsInfo;
    }

    private function createParameterRenderer(color:uint, alpha:Number, outlineColor:uint, outlineWidth:Number, geometryType:String):IRenderer
    {
        return new SimpleRenderer(createDefaultSymbolFromGeometry(geometryType, color, alpha, outlineColor, outlineWidth));
    }

    private function createDefaultSymbolFromGeometry(geometryType:String, color:uint, alpha:Number, outlineColor:uint, outlineWidth:Number):Symbol
    {
        var defaultSymbol:Symbol;

        if (geometryType == FeatureLayerParameter.POINT)
        {
            defaultSymbol = createDefaultPointSymbol(color, alpha, outlineColor, outlineWidth);
        }
        else if (geometryType == FeatureLayerParameter.POLYGON)
        {
            defaultSymbol = createDefaultPolygonSymbol(color, alpha, outlineColor, outlineWidth);
        }
        else if (geometryType == FeatureLayerParameter.POLYLINE)
        {
            defaultSymbol = createDefaultPolylineSymbol(outlineColor, alpha, outlineWidth);
        }
        else
        {
            defaultSymbol = createDefaultPointSymbol(color, alpha, outlineColor, outlineWidth);
        }

        return defaultSymbol;
    }

    //TODO: parameter order consistency
    protected function createDefaultPointSymbol(color:uint, alpha:Number, outlineColor:uint, outlineWidth:Number):SimpleMarkerSymbol
    {
        return new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 15, color, alpha, 0, 0, 0, createDefaultPolylineSymbol(outlineColor, alpha, outlineWidth));
    }

    //TODO: parameter order consistency
    protected function createDefaultPolygonSymbol(color:uint, alpha:Number, outlineColor:uint, outlineWidth:Number):SimpleFillSymbol
    {
        return new SimpleFillSymbol(SimpleFillSymbol.STYLE_SOLID, color, alpha, createDefaultPolylineSymbol(outlineColor, alpha, outlineWidth));
    }

    //TODO: parameter order consistency
    protected function createDefaultPolylineSymbol(color:uint, alpha:Number, width:Number):SimpleLineSymbol
    {
        return new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, color, alpha, width);
    }
}
}
