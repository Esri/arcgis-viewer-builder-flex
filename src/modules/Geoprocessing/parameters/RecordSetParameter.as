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

import modules.Geoprocessing.paramEditor.NonEditableParamView;
import modules.Geoprocessing.paramEditor.UnsupportedParamView;

import mx.core.IVisualElement;

public class RecordSetParameter extends BaseParameter implements IGPParameter
{
    override public function get type():String
    {
        return GPParameterTypes.RECORD_SET;
    }

    override public function defaultValueFromString(text:String):void
    {
        //NOT SUPPORTED - OUTPUT PARAM ONLY
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

        if (toolTip)
        {
            paramXML.@tooltip = toolTip;
        }

        return paramXML;
    }

    override public function createInputEditorView():IVisualElement
    {
        return new UnsupportedParamView();
    }

    override public function createOutputEditorView():IVisualElement
    {
        return new NonEditableParamView();
    }
}

}
