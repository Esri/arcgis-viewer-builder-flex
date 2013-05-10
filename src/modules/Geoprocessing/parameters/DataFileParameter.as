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

import com.esri.ags.tasks.supportClasses.DataFile;

import modules.Geoprocessing.paramEditor.NonEditableParamView;
import modules.Geoprocessing.paramEditor.input.InputDataFileParamEditor;

import mx.core.IVisualElement;

public class DataFileParameter extends BaseParameter
{
    private static const URL_DELIMITER:String = "url:";

    private function dataFileString():String
    {
        return URL_DELIMITER + _defaultValue.url;
    }

    private var _defaultValue:DataFile;

    override public function get defaultValue():Object
    {
        return _defaultValue;
    }

    override public function set defaultValue(value:Object):void
    {
        if (value)
        {
            var dataFile:DataFile = new DataFile();
            if (value.url)
            {
                dataFile.url = value.url;
            }
            _defaultValue = dataFile;
        }
    }

    override public function get type():String
    {
        return GPParameterTypes.DATA_FILE;
    }

    override public function defaultValueFromString(text:String):void
    {
        var url:String = text.substr(URL_DELIMITER.length, text.length);
        _defaultValue = new DataFile(url);
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

        if (defaultValue)
        {
            paramXML.@defaultvalue = dataFileString();
        }

        if (toolTip)
        {
            paramXML.@tooltip = toolTip;
        }

        return paramXML;
    }

    override public function createInputEditorView():IVisualElement
    {
        var editorView:InputDataFileParamEditor = new InputDataFileParamEditor();
        editorView.param = this;
        return editorView;
    }

    override public function createOutputEditorView():IVisualElement
    {
        return new NonEditableParamView();
    }
}

}
