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
package com.esri.builder.renderers
{

import com.esri.builder.components.IModifyItemDispatcher;

import spark.components.gridClasses.GridItemRenderer;

public class ModifiableGridItemRenderer extends GridItemRenderer implements IModifyItemDispatcher
{
    public function dispatchMoveItemUp(item:Object):void
    {
        (owner as IModifyItemDispatcher).dispatchMoveItemUp(item);
    }

    public function dispatchMoveItemDown(item:Object):void
    {
        (owner as IModifyItemDispatcher).dispatchMoveItemDown(item);
    }

    public function dispatchEditItem(item:Object):void
    {
        (owner as IModifyItemDispatcher).dispatchEditItem(item);
    }

    public function dispatchRemoveItem(item:Object):void
    {
        (owner as IModifyItemDispatcher).dispatchRemoveItem(item);
    }
}
}
