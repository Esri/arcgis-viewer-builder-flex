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

import mx.collections.IList;

import spark.components.supportClasses.ListBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.IndexChangeEvent;

[Event(name="fieldSelected", type="com.esri.builder.components.FieldPickerEvent")]
public class FieldPickerBase extends SkinnableComponent
{
    [SkinPart(required="true", type="spark.components.supportClasses.ListBase")]
    public var fieldList:ListBase;

    [Bindable]
    public var fields:IList;
    [Bindable]
    public var fieldLabelFunction:Function = defaultFieldLabelFunction;

    public function defaultFieldLabelFunction(field:Object):String
    {
        throw new Error("Must be subclassed!");
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == fieldList)
        {
            fieldList.addEventListener(IndexChangeEvent.CHANGE, fieldList_changeHandler, false, 0, true);
        }

        super.partAdded(partName, instance);
    }

    protected function fieldList_changeHandler(event:IndexChangeEvent):void
    {
        var fieldTemplate:String = "{" + selectedFieldNameAt(event.newIndex) + "}";
        fieldList.selectedIndex = ListBase.NO_SELECTION;
        dispatchEvent(new FieldPickerEvent(FieldPickerEvent.FIELD_SELECTED, fieldTemplate));
    }

    protected function selectedFieldNameAt(index:int):String
    {
        throw new Error("Must be subclassed!");
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == fieldList)
        {
            fieldList.removeEventListener(IndexChangeEvent.CHANGE, fieldList_changeHandler);
        }

        super.partRemoved(partName, instance);
    }
}
}
