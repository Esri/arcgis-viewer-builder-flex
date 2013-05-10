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

import com.esri.builder.components.ItemModifierDataGrid;
import com.esri.builder.components.ModifyItemEvent;

import mx.collections.IList;

import spark.components.supportClasses.SkinnableComponent;

public class KeyValueEditor extends SkinnableComponent
{
    [SkinPart(required="true")]
    public var fieldEditor:ItemModifierDataGrid;

    [Bindable]
    public var popUpFieldInfos:IList;

    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == fieldEditor)
        {
            fieldEditor.addEventListener(ModifyItemEvent.MOVE_ITEM_DOWN, popUpFieldsDataGrid_moveItemDownHandler);
            fieldEditor.addEventListener(ModifyItemEvent.MOVE_ITEM_UP, popUpFieldsDataGrid_moveItemUpHandler);
        }
    }

    protected function popUpFieldsDataGrid_moveItemDownHandler(event:ModifyItemEvent):void
    {
        var itemIndex:int = popUpFieldInfos.getItemIndex(event.item);

        var isItemAtBottom:Boolean = (itemIndex == (popUpFieldInfos.length - 1));
        if (isItemAtBottom)
        {
            return;
        }

        var removedItem:Object = popUpFieldInfos.removeItemAt(itemIndex);
        popUpFieldInfos.addItemAt(removedItem, ++itemIndex);
    }

    protected function popUpFieldsDataGrid_moveItemUpHandler(event:ModifyItemEvent):void
    {
        var itemIndex:int = popUpFieldInfos.getItemIndex(event.item);

        var isItemAtTop:Boolean = (itemIndex == 0);
        if (isItemAtTop)
        {
            return;
        }

        var removedItem:Object = popUpFieldInfos.removeItemAt(itemIndex);
        popUpFieldInfos.addItemAt(removedItem, --itemIndex);
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == fieldEditor)
        {
            fieldEditor.removeEventListener(ModifyItemEvent.MOVE_ITEM_DOWN, popUpFieldsDataGrid_moveItemDownHandler);
            fieldEditor.removeEventListener(ModifyItemEvent.MOVE_ITEM_UP, popUpFieldsDataGrid_moveItemUpHandler);
        }
    }
}
}
