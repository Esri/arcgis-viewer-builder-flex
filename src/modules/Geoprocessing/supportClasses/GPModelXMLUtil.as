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

import modules.Geoprocessing.GeoprocessingModel;
import modules.Geoprocessing.parameters.IGPParameter;

public class GPModelXMLUtil
{
    public static function toXML(model:GeoprocessingModel):XML
    {
        var configXML:XML =
            <configuration>
                <description>{model.description}</description>
                <taskurl>{model.taskURL}</taskurl>
                <helpurl>{model.helpURL}</helpurl>
                <autosubmit>{model.autoSubmit}</autosubmit>
                <shareresults>{model.shareResults}</shareresults>
            </configuration>;

        if (model.useProxy)
        {
            configXML.appendChild(<useproxy>true</useproxy>);
        }

        configXML.appendChild(createInputParamXML(model));
        configXML.appendChild(createOutputParamXML(model));
        configXML.appendChild(createLayerOrderXML(model));

        return configXML;
    }

    private static function createOutputParamXML(model:GeoprocessingModel):XML
    {
        var outputParamsXML:XML = <outputparams></outputparams>;
        var configOutputParams:Array = model.outputParams;
        appendGPParams(outputParamsXML, configOutputParams);

        return outputParamsXML;
    }

    private static function createLayerOrderXML(model:GeoprocessingModel):XML
    {
        return <layerorder>{model.layerOrder.toString()}</layerorder>;
    }

    private static function createInputParamXML(model:GeoprocessingModel):XML
    {
        var inputParamsXML:XML = <inputparams></inputparams>;
        var configInputParams:Array = model.inputParams;
        appendGPParams(inputParamsXML, configInputParams);

        return inputParamsXML;
    }

    private static function appendGPParams(gpParamsXML:XML, params:Array):void
    {
        for each (var gpParam:IGPParameter in params)
        {
            gpParamsXML.appendChild(gpParam.toXML());
        }
    }
}

}
