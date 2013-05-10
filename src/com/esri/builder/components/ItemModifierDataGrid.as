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

import com.esri.builder.renderers.ModifiableGridItemRenderer;

import mx.collections.IList;

import spark.components.DataGrid;
import spark.events.GridEvent;

[Event(name="editItem", type="com.esri.builder.components.ModifyItemEvent")]
[Event(name="moveItemUp", type="com.esri.builder.components.ModifyItemEvent")]
[Event(name="moveItemDown", type="com.esri.builder.components.ModifyItemEvent")]
[Event(name="removeItem", type="com.esri.builder.components.ModifyItemEvent")]
public class ItemModifierDataGrid extends DataGrid implements IModifyItemDispatcher
{
    public function ItemModifierDataGrid()
    {
        addEventListener(GridEvent.GRID_DOUBLE_CLICK, this_gridDoubleClickHandler, false, 0, true);
        doubleClickEnabled = true;
    }

    protected function this_gridDoubleClickHandler(event:GridEvent):void
    {
        if (doubleClickEnabled && event.rowIndex > -1
            && !(event.itemRenderer is ModifiableGridItemRenderer))
        {
            dispatchEditItem(dataProvider.getItemAt(event.rowIndex));
        }
    }

    public function dispatchMoveItemUp(item:Object):void
    {
        dispatchEvent(new ModifyItemEvent(ModifyItemEvent.MOVE_ITEM_UP, item));
    }

    public function dispatchMoveItemDown(item:Object):void
    {
        dispatchEvent(new ModifyItemEvent(ModifyItemEvent.MOVE_ITEM_DOWN, item));
    }

    public function dispatchEditItem(item:Object):void
    {
        dispatchEvent(new ModifyItemEvent(ModifyItemEvent.EDIT_ITEM, item));
    }

    public function dispatchRemoveItem(item:Object):void
    {
        dispatchEvent(new ModifyItemEvent(ModifyItemEvent.REMOVE_ITEM, item));
    }

    //helper methods for common operations
    public static function moveItemDown(item:Object, dataProvider:IList):void
    {
        if (!dataProvider)
        {
            return;
        }

        const itemIndex:int = dataProvider.getItemIndex(item);

        if (itemIndex < 0)
        {
            return;
        }

        const isItemAtBottom:Boolean = (itemIndex == (dataProvider.length - 1));
        if (isItemAtBottom)
        {
            return;
        }

        const removedItem:Object = dataProvider.removeItemAt(itemIndex);
        dataProvider.addItemAt(removedItem, ++itemIndex);
    }

    public static function moveItemUp(item:Object, dataProvider:IList):void
    {
        if (!dataProvider)
        {
            return;
        }

        const itemIndex:int = dataProvider.getItemIndex(item);

        if (itemIndex < 0)
        {
            return;
        }

        const isItemAtTop:Boolean = (itemIndex == 0);
        if (isItemAtTop)
        {
            return;
        }

        const removedItem:Object = dataProvider.removeItemAt(itemIndex);
        dataProvider.addItemAt(removedItem, --itemIndex);
    }

    public static function removeItem(item:Object, dataProvider:IList):void
    {
        if (!dataProvider)
        {
            return;
        }

        const itemIndex:int = dataProvider.getItemIndex(item);
        if (itemIndex > -1)
        {
            dataProvider.removeItemAt(itemIndex);
        }
    }
}
}
