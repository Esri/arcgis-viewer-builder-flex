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
package modules.Geoprocessing
{

import com.esri.builder.supportClasses.URLUtil;

import modules.Geoprocessing.parameters.IGPParameter;
import modules.Geoprocessing.parameters.UnsupportedParameter;
import modules.Geoprocessing.supportClasses.GPModelXMLUtil;
import modules.Geoprocessing.supportClasses.GPParamParser;
import modules.IWidgetModel;

[Bindable]
public class GeoprocessingModel implements IWidgetModel
{
    public var autoSubmit:Boolean;

    public var shareResults:Boolean = false;

    private var _helpURL:String = "";

    public function get helpURL():String
    {
        return _helpURL;
    }

    public function set helpURL(value:String):void
    {
        _helpURL = value;
    }

    private var _taskURL:String;

    public function get taskURL():String
    {
        return _taskURL;
    }

    public function set taskURL(value:String):void
    {
        _taskURL = URLUtil.encode(value);
    }

    private var _description:String = "";

    public function get description():String
    {
        return _description;
    }

    public function set description(value:String):void
    {
        _description = value;
    }

    private var _layerOrder:Array;

    public function get layerOrder():Array
    {
        return _layerOrder ||= [];
    }

    public function set layerOrder(value:Array):void
    {
        _layerOrder = value;
    }

    private var _inputParams:Array;

    public function get inputParams():Array
    {
        return _inputParams ||= [];
    }

    public function set inputParams(value:Array):void
    {
        _inputParams = value;
    }

    private var _outputParams:Array;

    public function get outputParams():Array
    {
        return _outputParams ||= [];
    }

    public function set outputParams(value:Array):void
    {
        _outputParams = value;
    }

    public function hasRequiredAndUnsupportedParams():Boolean
    {
        return findRequiredAndUnsupportedParam(_inputParams)
            || findRequiredAndUnsupportedParam(_outputParams);
    }

    //TODO: rename
    private function findRequiredAndUnsupportedParam(params:Array):Boolean
    {
        var foundRequiredAndUnsupportedParam:Boolean;

        for each (var param:IGPParameter in params)
        {
            if (param.required && param is UnsupportedParameter)
            {
                foundRequiredAndUnsupportedParam = true;
                break;
            }
        }

        return foundRequiredAndUnsupportedParam;
    }

    public var useProxy:Boolean;

    public function importXML(doc:XML):void
    {
        description = doc.description;
        taskURL = doc.taskurl;
        helpURL = doc.helpurl;
        useProxy = doc.useproxy == 'true';
        shareResults = doc.shareresults[0] == "true";

        if (doc.autosubmit[0])
        {
            autoSubmit = (doc.autosubmit == "true");
        }

        var gpParamParser:GPParamParser = new GPParamParser();

        if (doc.inputparams[0])
        {
            _inputParams = gpParamParser.parseParameters(doc.inputparams.param);
        }

        if (doc.outputparams[0])
        {
            _outputParams = gpParamParser.parseParameters(doc.outputparams.param);
        }

        if (doc.layerorder[0])
        {
            var delimitedLayerNames:String = doc.layerorder;
            if (delimitedLayerNames)
            {
                layerOrder = delimitedLayerNames.split(',');
            }
        }
    }

    public function exportXML():XML
    {
        return GPModelXMLUtil.toXML(this);
    }
}

}
