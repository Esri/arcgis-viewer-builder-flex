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

import mx.collections.ArrayList;

public class WidgetTypeRegistry
{
    [Bindable]
    public var widgetTypes:ArrayList = new ArrayList(); // List of loaded widget infos under the app modules folder.

    public function addWidgetType(widgetType:WidgetType):void
    {
        var existingWidgetType:WidgetType = findWidgetTypeByName(widgetType.name);
        removeWidgetType(existingWidgetType);
        widgetTypes.addItem(widgetType);
    }

    public function findWidgetTypeByName(name:String):WidgetType
    {
        var foundWidgetType:WidgetType;
        var widgetTypes:Array = widgetTypes.source;
        for each (var widgetType:WidgetType in widgetTypes)
        {
            if (widgetType.name == name)
            {
                foundWidgetType = widgetType;
                break;
            }
        }

        return foundWidgetType;
    }

    public function removeWidgetType(widgetType:WidgetType):void
    {
        widgetTypes.removeItem(widgetType);
    }

    public function findWidgetTypeByURL(url:String):WidgetType
    {
        var foundWidgetType:WidgetType;
        var widgetTypes:Array = widgetTypes.source;
        for each (var widgetType:WidgetType in widgetTypes)
        {
            const widgetTypeURL:String = widgetType.url;
            if (widgetTypeURL === url)
            {
                foundWidgetType = widgetType;
                break;
            }
        }

        return foundWidgetType;
    }

    public function clearWidgetTypes():void
    {
        widgetTypes.source = [];
    }
}
}
