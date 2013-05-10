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

import modules.Geoprocessing.paramEditor.UnsupportedParamView;

import mx.core.IVisualElement;

public class UnsupportedParameter extends BaseParameter implements IGPParameter
{
    private var _type:String;

    public function UnsupportedParameter(type:String)
    {
        _type = type;
    }

    override public function get type():String
    {
        return _type;
    }

    override public function createInputEditorView():IVisualElement
    {
        return new UnsupportedParamView();
    }

    override public function createOutputEditorView():IVisualElement
    {
        return new UnsupportedParamView();
    }
}
}
