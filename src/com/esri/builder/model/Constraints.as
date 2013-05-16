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

[Bindable]
public class Constraints implements IConstraints
{
    public function Constraints(left:String = "", top:String = "", right:String = "", bottom:String = "")
    {
        _left = left;
        _top = top;
        _right = right;
        _bottom = bottom;
    }

    private var _left:String;

    public function get left():String
    {
        return _left;
    }

    public function set left(value:String):void
    {
        _left = value;
    }

    private var _top:String;

    public function get top():String
    {
        return _top;
    }

    public function set top(value:String):void
    {
        _top = value;
    }

    private var _right:String;

    public function get right():String
    {
        return _right;
    }

    public function set right(value:String):void
    {
        _right = value;
    }

    private var _bottom:String;

    public function get bottom():String
    {
        return _bottom;
    }

    public function set bottom(value:String):void
    {
        _bottom = value;
    }

    public function clone():IConstraints
    {
        return new Constraints(left, top, right, bottom);
    }
}
}
