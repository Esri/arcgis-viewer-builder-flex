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
public class Widget extends Constraints implements IXMLEncoder, IWidget
{
    public var widgetXML:XML; // The original XML from main config.xml

    public var isManaged:Boolean = false;

    public var config:String; // configuration URL

    public var url:String; // SWF module URL

    public var preload:Boolean;

    public var iconFile:File; // internal use

    private var _icon:String;

    public var isPartOfPanel:Boolean = false;

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

    public static function decodeXML(widgetXML:XML, isInContainer:Boolean, isPartOfPanel:Boolean = false):Widget
    {
        const widget:Widget = new Widget();
        widget.widgetXML = widgetXML;
        widget.isManaged = isInContainer;
        widget.isPartOfPanel = isPartOfPanel;
        widget.label = widgetXML.@label;
        widget.icon = widgetXML.@icon;
        widget.iconFile = Model.instance.appDir.resolvePath(widget.icon);
        widget.config = widgetXML.@config;
        widget.url = widgetXML.@url;
        const preload:String = widgetXML.@preload;
        widget.preload = preload === 'open';
        widget.left = widgetXML.@left;
        widget.right = widgetXML.@right;
        widget.top = widgetXML.@top;
        widget.bottom = widgetXML.@bottom;
        widget.name = toWidgetName(widget.config, widget.label);
        return widget;
    }

    private static function toWidgetName(config:String, label:String):String
    {
        const re:RegExp = /^.+Widget_?(.*)\.xml$/;
        const arr:Array = re.exec(config);
        if (arr && arr.length === 2 && arr[1] !== '')
        {
            return arr[1];
        }
        return label.replace(/\s+/g, '_');
    }

    //assumes the widget config follows convention: [WidgetType]Widget(_[ConfigName]).xml
    public static function widgetTypeNameFromConfig(config:String):String
    {
        var widgetName:String;
        const widgetNamePattern:RegExp = /^.+\/(.+)Widget.*\.xml$/;
        const matches:Array = widgetNamePattern.exec(config);

        if (matches
            && matches.length === 2
            && matches[1] !== '')
        {
            widgetName = matches[1];
        }

        return widgetName;
    }

    public function encodeXML(targetXML:XML = null):XML
    {
        var xml:XML = targetXML;
        if (xml == null)
        {
            xml = <widget url={url} config={config}/>;
        }
        if (label)
        {
            xml.@label = label;
        }
        else
        {
            delete xml.@label;
        }
        if (icon)
        {
            xml.@icon = icon;
        }
        else
        {
            delete xml.@icon;
        }
        if (preload)
        {
            xml.@preload = 'open';
        }
        else
        {
            delete xml.@preload;
        }
        if (left)
        {
            xml.@left = left;
        }
        else
        {
            delete xml.@left;
        }
        if (right)
        {
            xml.@right = right;
        }
        else
        {
            delete xml.@right;
        }
        if (top)
        {
            xml.@top = top;
        }
        else
        {
            delete xml.@top;
        }
        if (bottom)
        {
            xml.@bottom = bottom;
        }
        else
        {
            delete xml.@bottom;
        }
        return xml;
    }

    public function toString():String
    {
        return "Widget{config:\"" + config + "\", icon:\"" + _icon + "\", name:\"" + _name + "\"}";
    }

    public function clone():Widget
    {
        const widget:Widget = new Widget();
        widget.isManaged = isManaged;
        widget.isPartOfPanel = isPartOfPanel;
        widget.name = name;
        widget.label = label;
        widget.icon = icon;
        widget.iconFile = iconFile;
        widget.config = config;
        widget.url = url;
        widget.preload = preload;
        widget.left = left;
        widget.right = right;
        widget.top = top;
        widget.bottom = bottom;
        return widget;
    }
}

}
