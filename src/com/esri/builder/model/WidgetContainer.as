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

import flash.utils.Dictionary;

public final class WidgetContainer implements IConstraints
{
    public var layout:String;

    public var panelType:String;

    public var initialState:String = "open";

    public var children:Array;

    public function WidgetContainer(children:Array)
    {
        this.children = children;
    }

    private var _constraints:IConstraints = new Constraints();

    public function get left():String
    {
        return _constraints.left;
    }

    public function set left(value:String):void
    {
        _constraints.left = value;
    }

    public function get top():String
    {
        return _constraints.top;
    }

    public function set top(value:String):void
    {
        _constraints.top = value;
    }

    public function get right():String
    {
        return _constraints.right;
    }

    public function set right(value:String):void
    {
        _constraints.right = value;
    }

    public function get bottom():String
    {
        return _constraints.bottom;
    }

    public function set bottom(value:String):void
    {
        _constraints.bottom = value;
    }

    public static function decodeXML(widgetContainerXML:XML):WidgetContainer
    {
        const widgetContainer:WidgetContainer = new WidgetContainer([]);
        var isPanel:Boolean;
        if (widgetContainerXML.@paneltype[0])
        {
            isPanel = true;
            widgetContainer.panelType = widgetContainerXML.@paneltype;
            if (widgetContainerXML.@initialstate[0])
            {
                widgetContainer.initialState = widgetContainerXML.@initialstate;
            }
        }
        else
        {
            widgetContainer.left = widgetContainerXML.@left;
            widgetContainer.right = widgetContainerXML.@right;
            widgetContainer.top = widgetContainerXML.@top;
            widgetContainer.bottom = widgetContainerXML.@bottom;
            widgetContainer.layout = widgetContainerXML.@layout;
        }

        widgetContainer.children = [];

        for each (var childXML:XML in widgetContainerXML.children())
        {
            const tagName:String = childXML.name();
            if (tagName === 'widget')
            {
                widgetContainer.children.push(Widget.decodeXML(childXML, true, isPanel));
            }
            else if (tagName === 'widgetgroup')
            {
                widgetContainer.children.push(WidgetGroup.decodeXML(childXML));
            }
        }

        return widgetContainer;
    }

    public function encodeXML(targetXML:XML = null):XML
    {
        var widgetContainerXML:XML = targetXML;
        if (widgetContainerXML == null)
        {
            widgetContainerXML = <widgetcontainer/>;
        }
        if (panelType)
        {
            widgetContainerXML.@paneltype = panelType;
            widgetContainerXML.@initialstate = initialState;
        }
        else
        {
            if (layout)
            {
                widgetContainerXML.@layout = layout;
            }
            if (left)
            {
                widgetContainerXML.@left = left;
            }
            if (right)
            {
                widgetContainerXML.@right = right;
            }
            if (top)
            {
                widgetContainerXML.@top = top;
            }
            if (bottom)
            {
                widgetContainerXML.@botton = bottom;
            }
        }

        var existingWidgetXML:Dictionary = getExistingWidgetXMLMap(widgetContainerXML);
        removeAllWidgets(widgetContainerXML);
        appendEncodedXML(widgetContainerXML, existingWidgetXML);
        return widgetContainerXML;
    }

    private function getExistingWidgetXMLMap(widgetContainerXML:XML):Dictionary
    {
        var existingWidgetXMLMap:Dictionary = new Dictionary(true);

        for each (var xmlEncoder:IXMLEncoder in children)
        {
            if (xmlEncoder is Widget)
            {
                var originalWidgetXML:XML = findOriginalWidgetXML(widgetContainerXML, xmlEncoder as Widget);
                if (originalWidgetXML)
                {
                    existingWidgetXMLMap[xmlEncoder] = (xmlEncoder as Widget).encodeXML(originalWidgetXML.copy());
                }
            }
        }

        return existingWidgetXMLMap;
    }

    private function findOriginalWidgetXML(targetXML:XML, widget:Widget):XML
    {
        var widgetXMLList:XMLList = targetXML.child("widget");
        for each (var temp:XML in widgetXMLList)
        {
            if (temp.@config == widget.config)
            {
                return temp;
            }
        }
        return null;
    }

    private function removeAllWidgets(targetXML:XML):void
    {
        var widgetXMLList:XMLList = targetXML.child("widget");
        var totalWidgetChildren:int = widgetXMLList.length();
        for (var i:int = totalWidgetChildren - 1; i > -1; i--)
        {
            delete widgetXMLList[i];
        }
    }

    private function appendEncodedXML(widgetContainerXML:XML, existingWidgetXML:Dictionary):void
    {
        var encodedXML:XML;
        for each (var xmlEncoder:IXMLEncoder in children)
        {
            if (existingWidgetXML[xmlEncoder])
            {
                encodedXML = existingWidgetXML[xmlEncoder];
            }
            else
            {
                encodedXML = xmlEncoder.encodeXML();
            }

            widgetContainerXML.appendChild(encodedXML);
        }
    }
}

}
