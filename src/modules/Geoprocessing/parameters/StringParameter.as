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
import modules.Geoprocessing.paramEditor.input.InputStringParamEditor;

import mx.core.IVisualElement;

public class StringParameter extends BaseParameter
{
    private var _defaultValue:String;

    override public function get defaultValue():Object
    {
        return _defaultValue;
    }

    override public function set defaultValue(value:Object):void
    {
        _defaultValue = value as String;
    }

    override public function get type():String
    {
        return GPParameterTypes.STRING;
    }

    override public function createInputEditorView():IVisualElement
    {
        var editorView:InputStringParamEditor = new InputStringParamEditor();
        editorView.param = this;
        return editorView;
    }

    override public function createOutputEditorView():IVisualElement
    {
        return new NonEditableParamView()
    }
}

}
