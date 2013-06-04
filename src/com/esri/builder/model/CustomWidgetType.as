////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2016 Esri. All Rights Reserved.
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
package com.esri.builder.model
{
import modules.IBuilderModule;
import modules.IWidgetModel;

public class CustomWidgetType extends WidgetType
{
    public function CustomWidgetType(builderModule:IBuilderModule, version:String = null, configXML:XML = null)
    {
        super(builderModule);
        this._version = version;
        this._configXML = configXML;
    }

    private var _version:String;

    public function get version():String
    {
        return _version;
    }

    private var _configXML:XML;

    public function get configXML():XML
    {
        return _configXML;
    }

    override public function createWidgetModel():IWidgetModel
    {
        var widgetModel:IWidgetModel = super.createWidgetModel();
        if (configXML)
        {
            widgetModel.importXML(configXML);
        }
        return widgetModel;
    }
}
}
