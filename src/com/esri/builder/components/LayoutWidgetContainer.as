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
package com.esri.builder.components
{

import flash.events.Event;
import flash.events.MouseEvent;

import spark.components.SkinnableContainer;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.TextBase;
import spark.components.supportClasses.ToggleButtonBase;

[Event(name="inclusionChange", type="com.esri.builder.components.LayoutWidgetContainerEvent")]
[Event(name="editClick", type="com.esri.builder.components.LayoutWidgetContainerEvent")]
public class LayoutWidgetContainer extends SkinnableContainer
{
    [SkinPart(required="true", type="spark.components.supportClasses.TextBase")]
    public var labelDisplay:TextBase;
    [SkinPart(required="false", type="spark.components.supportClasses.ToggleButtonBase")]
    public var inclusionOption:ToggleButtonBase;
    [SkinPart(required="false", type="spark.components.supportClasses.ButtonBase")]
    public var editButton:ButtonBase;

    [Bindable]
    public var label:String;
    [Bindable]
    public var included:Boolean;
    [Bindable]
    public var isLayoutWidgetPartOfPanel:Boolean;

    override protected function getCurrentSkinState():String
    {
        return isLayoutWidgetPartOfPanel ? enabled ? "normalpanel" : "disabledpanel" : enabled ? "normal" : "disabled";
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == inclusionOption)
        {
            inclusionOption.addEventListener(Event.CHANGE, inclusionOption_changeHandler, false, 0, true);
        }
        else if (instance == editButton)
        {
            editButton.addEventListener(MouseEvent.CLICK, editButton_clickHandler, false, 0, true);
        }

        super.partAdded(partName, instance);
    }

    protected function inclusionOption_changeHandler(event:Event):void
    {
        dispatchEvent(new LayoutWidgetContainerEvent(LayoutWidgetContainerEvent.INCLUSION_CHANGE, inclusionOption.selected));
    }

    protected function editButton_clickHandler(event:MouseEvent):void
    {
        dispatchEvent(new LayoutWidgetContainerEvent(LayoutWidgetContainerEvent.EDIT_CLICK));
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == inclusionOption)
        {
            inclusionOption.removeEventListener(Event.CHANGE, inclusionOption_changeHandler);
        }
        else if (instance == editButton)
        {
            editButton.removeEventListener(MouseEvent.CLICK, editButton_clickHandler);
        }
        super.partRemoved(partName, instance);
    }
}
}
