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

import com.esri.ags.tasks.supportClasses.LinearUnit;

import modules.Geoprocessing.paramEditor.NonEditableParamView;
import modules.Geoprocessing.paramEditor.input.InputLinearUnitParamEditor;
import modules.Geoprocessing.supportClasses.UnitMappingUtil;

import mx.core.IVisualElement;

public class LinearUnitParameter extends BaseParameter
{
    private function linearUnitString():String
    {
        return _defaultValue.distance + ":" + UnitMappingUtil.toPrettyUnits(_defaultValue.units);
    }

    private var _defaultValue:LinearUnit;

    override public function get defaultValue():Object
    {
        return _defaultValue;
    }

    override public function set defaultValue(value:Object):void
    {
        if (value)
        {
            var linearUnit:LinearUnit = new LinearUnit();
            if (value.distance)
            {
                linearUnit.distance = value.distance;
            }
            if (value.units)
            {
                linearUnit.units = value.units;
            }
            _defaultValue = linearUnit;
        }
    }

    override public function get type():String
    {
        return GPParameterTypes.LINEAR_UNIT;
    }

    override public function defaultValueFromString(text:String):void
    {
        var linearUnitTokens:Array = text.split(':');
        _defaultValue = new LinearUnit(linearUnitTokens[0], UnitMappingUtil.toEsriUnits((linearUnitTokens[1])));
    }

    override public function toXML():XML
    {
        var paramXML:XML = <param/>

        paramXML.@type = type;
        paramXML.@name = name;
        paramXML.@required = required;
        paramXML.@visible = visible;

        if (label)
        {
            paramXML.@label = label;
        }

        if (choiceList && choiceList.length > 0)
        {
            paramXML.appendChild(getChoiceListXML());
        }

        if (defaultValue)
        {
            paramXML.@defaultvalue = linearUnitString();
        }

        if (toolTip)
        {
            paramXML.@tooltip = toolTip;
        }

        return paramXML;
    }

    override public function createInputEditorView():IVisualElement
    {
        var editorView:InputLinearUnitParamEditor = new InputLinearUnitParamEditor()
        editorView.param = this;
        return editorView;
    }

    override public function createOutputEditorView():IVisualElement
    {
        return new NonEditableParamView();
    }
}

}
