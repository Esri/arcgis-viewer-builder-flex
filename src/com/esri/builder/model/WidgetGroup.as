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
package com.esri.builder.model
{

import flash.filesystem.File;

[Bindable]
public final class WidgetGroup implements IXMLEncoder, IWidget
{
    public var widgets:Array;

    public var iconFile:File; // internal use

    private var _icon:String;

    public function get icon():String
    {
        return _icon;
    }

    public function set icon(value:String):void
    {
        _icon = value;
    }

    private var _label:String;

    public function get label():String
    {
        return _label;
    }

    public function set label(value:String):void
    {
        _label = value;
    }

    private var _name:String;

    public function get name():String
    {
        return _name;
    }

    public function set name(value:String):void
    {
        _name = value;
    }

    private var _toolTip:String;

    public function get toolTip():String
    {
        return _toolTip;
    }

    public function set toolTip(value:String):void
    {
        _toolTip = value;
    }

    public static function decodeXML(widgetGroupXML:XML):WidgetGroup
    {
        const widgetGroup:WidgetGroup = new WidgetGroup();

        widgetGroup.label = widgetGroupXML.@label;
        widgetGroup.icon = widgetGroupXML.@icon;

        const iconPath:String = widgetGroup.icon ? widgetGroup.icon : "assets/images/i_folder.png";
        widgetGroup.iconFile = Model.instance.appDir.resolvePath(iconPath);

        widgetGroup.widgets = [];
        for each (var widgetXML:XML in widgetGroupXML.widget)
        {
            widgetGroup.widgets.push(Widget.decodeXML(widgetXML, true));
        }

        return widgetGroup;
    }

    public function encodeXML(targetXML:XML = null):XML
    {
        const configXML:XML = <widgetgroup/>;

        if (label)
        {
            configXML.@label = label;
        }

        if (icon)
        {
            configXML.@icon = icon;
        }

        for each (var widget:Widget in widgets)
        {
            configXML.appendChild(widget.encodeXML());
        }

        return configXML;
    }

    public function toString():String
    {
        return "WidgetGroup " + this.name + "\t" + this.label + "\t" + this.icon
            + "\tchildren: " + (this.widgets ? this.widgets.length : 0);
    }
}
}
