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

import mx.core.FlexGlobals;
import mx.core.LayoutDirection;

[Bindable]
public class LTRConstraints extends Constraints
{
    public function LTRConstraints(left:String = "", top:String = "", right:String = "", bottom:String = "")
    {
        super(left, top, right, bottom);
    }

    override public function get left():String
    {
        return isLTR ? super.left : super.right;
    }

    override public function set left(value:String):void
    {
        super.left = value;
    }

    private function get isLTR():Boolean
    {
        return FlexGlobals.topLevelApplication.getStyle('layoutDirection') == LayoutDirection.LTR;
    }

    override public function get right():String
    {
        return isLTR ? super.right : super.left;
    }

    override public function set right(value:String):void
    {
        super.right = value;
    }

    override public function clone():IConstraints
    {
        return new LTRConstraints(super.left, super.top, super.right, super.bottom);
    }
}
}
