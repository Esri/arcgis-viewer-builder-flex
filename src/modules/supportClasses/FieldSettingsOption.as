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

[Bindable]
public class FieldSettingsOption
{
    private var _settings:FieldSettings;

    public function FieldSettingsOption(settings:FieldSettings)
    {
        _settings = settings;
    }

    public function get settings():FieldSettings
    {
        return _settings;
    }

    public function get name():String
    {
        return _settings.name;
    }

    public function set name(value:String):void
    {
        _settings.name = value;
    }

    public function get alias():String
    {
        return _settings.alias;
    }

    public function set alias(value:String):void
    {
        _settings.alias = value;
    }

    public function get required():Boolean
    {
        return _settings.required;
    }

    public function set required(value:Boolean):void
    {
        _settings.required = value;
    }

    public var isRequiredEditable:Boolean;
    public var isEditorTrackingField:Boolean;
    public var selected:Boolean;
    public var editable:Boolean;
    public var originalAlias:String;
}
}
