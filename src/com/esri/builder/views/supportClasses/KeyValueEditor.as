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
package com.esri.builder.views.supportClasses
{

import com.esri.ags.layers.supportClasses.Field;
import com.esri.ags.portal.supportClasses.PopUpFieldFormat;
import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.builder.components.ItemModifierDataGrid;
import com.esri.builder.components.ModifyItemEvent;
import com.esri.builder.views.popups.FieldFormatPopUp;

import flash.display.DisplayObjectContainer;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.core.FlexGlobals;

import spark.components.supportClasses.SkinnableComponent;
import spark.events.PopUpEvent;

public class KeyValueEditor extends SkinnableComponent
{
    [SkinPart(required="true")]
    public var fieldEditor:ItemModifierDataGrid;

    private var editedFieldInfo:PopUpFieldInfo;

    private var _popUpFieldInfos:IList;

    [Bindable]
    public function get popUpFieldInfos():IList
    {
        return _popUpFieldInfos;
    }

    public function set popUpFieldInfos(value:IList):void
    {
        _popUpFieldInfos = value;
        invalidateProperties();
    }

    [Bindable]
    private var _fields:IList;

    public function get fields():IList
    {
        return _fields;
    }

    public function set fields(value:IList):void
    {
        _fields = value;
        invalidateProperties();
    }

    override protected function commitProperties():void
    {
        if (!fieldNameToFieldLookUp
            && _fields && _popUpFieldInfos)
        {
            initFieldNameToFieldLookUp();
        }

        super.commitProperties();
    }

    public var fieldNameToFieldLookUp:Dictionary;

    private function initFieldNameToFieldLookUp():void
    {
        fieldNameToFieldLookUp = new Dictionary();

        for each (var field:Field in _fields.toArray())
        {
            fieldNameToFieldLookUp[field.name] = field;
        }
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == fieldEditor)
        {
            fieldEditor.addEventListener(ModifyItemEvent.MOVE_ITEM_DOWN, popUpFieldsDataGrid_moveItemDownHandler);
            fieldEditor.addEventListener(ModifyItemEvent.MOVE_ITEM_UP, popUpFieldsDataGrid_moveItemUpHandler);
            fieldEditor.addEventListener(ModifyItemEvent.EDIT_ITEM, popUpFieldsDataGrid_editItemHandler);
        }
    }

    protected function popUpFieldsDataGrid_moveItemDownHandler(event:ModifyItemEvent):void
    {
        var itemIndex:int = _popUpFieldInfos.getItemIndex(event.item);

        var isItemAtBottom:Boolean = (itemIndex == (_popUpFieldInfos.length - 1));
        if (isItemAtBottom)
        {
            return;
        }

        var removedItem:Object = _popUpFieldInfos.removeItemAt(itemIndex);
        _popUpFieldInfos.addItemAt(removedItem, ++itemIndex);
    }

    protected function popUpFieldsDataGrid_moveItemUpHandler(event:ModifyItemEvent):void
    {
        var itemIndex:int = _popUpFieldInfos.getItemIndex(event.item);

        var isItemAtTop:Boolean = (itemIndex == 0);
        if (isItemAtTop)
        {
            return;
        }

        var removedItem:Object = _popUpFieldInfos.removeItemAt(itemIndex);
        _popUpFieldInfos.addItemAt(removedItem, --itemIndex);
    }

    private function popUpFieldsDataGrid_editItemHandler(event:ModifyItemEvent):void
    {
        var fieldFormatPopUp:FieldFormatPopUp = new FieldFormatPopUp();
        editedFieldInfo = event.item as PopUpFieldInfo;

        fieldFormatPopUp.field = findMatchingField(editedFieldInfo.fieldName);
        if (editedFieldInfo.format)
        {
            fieldFormatPopUp.overrideFieldFormat(editedFieldInfo.format);
        }
        fieldFormatPopUp.addEventListener(PopUpEvent.CLOSE, fieldFormatPopUp_closeHandler);
        fieldFormatPopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    public function findMatchingField(fieldName:String):Field
    {
        return fieldNameToFieldLookUp ? fieldNameToFieldLookUp[fieldName] : null;
    }

    private function fieldFormatPopUp_closeHandler(event:PopUpEvent):void
    {
        var fieldFormatPopUp:FieldFormatPopUp = event.currentTarget as FieldFormatPopUp;
        fieldFormatPopUp.removeEventListener(PopUpEvent.CLOSE, fieldFormatPopUp_closeHandler);
        if (event.commit)
        {
            editedFieldInfo.format = event.data.fieldFormat as PopUpFieldFormat;
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == fieldEditor)
        {
            fieldEditor.removeEventListener(ModifyItemEvent.MOVE_ITEM_DOWN, popUpFieldsDataGrid_moveItemDownHandler);
            fieldEditor.removeEventListener(ModifyItemEvent.MOVE_ITEM_UP, popUpFieldsDataGrid_moveItemUpHandler);
            fieldEditor.removeEventListener(ModifyItemEvent.EDIT_ITEM, popUpFieldsDataGrid_editItemHandler);
        }
    }
}
}
