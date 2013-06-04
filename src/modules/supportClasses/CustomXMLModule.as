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
package modules.supportClasses
{

import modules.IBuilderModule;
import modules.IWidgetModel;
import modules.IWidgetView;

public class CustomXMLModule implements IBuilderModule
{
    public function get isManaged():Boolean
    {
        return true;
    }

    private var _isOpenByDefault:Boolean = false;

    public function get isOpenByDefault():Boolean
    {
        return _isOpenByDefault;
    }

    public function set isOpenByDefault(value:Boolean):void
    {
        _isOpenByDefault = value;
    }

    private var _widgetName:String

    public function get widgetName():String
    {
        return _widgetName;
    }

    public function set widgetName(value:String):void
    {
        _widgetName = value;
    }

    private var _widgetDescription:String;

    public function get widgetDescription():String
    {
        return _widgetDescription;
    }

    public function set widgetDescription(value:String):void
    {
        _widgetDescription = value;
    }

    private var _widgetIconLocation:String;

    public function get widgetIconLocation():String
    {
        return _widgetIconLocation;
    }

    public function set widgetIconLocation(value:String):void
    {
        _widgetIconLocation = value;
    }

    private var _widgetLabel:String;

    public function get widgetLabel():String
    {
        return _widgetLabel;
    }

    public function set widgetLabel(value:String):void
    {
        _widgetLabel = value;
    }

    private var _widgetHelpURL:String;

    public function get widgetHelpURL():String
    {
        return _widgetHelpURL;
    }

    public function set widgetHelpURL(value:String):void
    {
        _widgetHelpURL = value;
    }

    public function createWidgetView():IWidgetView
    {
        return new XMLWidgetView();
    }

    public function createWidgetModel():IWidgetModel
    {
        return new XMLWidgetModel();
    }
}
}
