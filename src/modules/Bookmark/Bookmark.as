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
package modules.Bookmark
{

[Bindable]
public final class Bookmark
{
    public var name:String;

    public var xmin:Number;

    public var ymin:Number;

    public var xmax:Number;

    public var ymax:Number;

    public var isNew:Boolean;

    public var isEditing:Boolean;

    public function Bookmark(name:String = null, xmin:Number = 0, ymin:Number = 0, xmax:Number = 0, ymax:Number = 0)
    {
        this.name = name;
        this.xmin = xmin;
        this.ymin = ymin;
        this.xmax = xmax;
        this.ymax = ymax;
    }

    public function encodeXML():XML
    {
        return <bookmark name={name}>{xmin} {ymin} {xmax} {ymax}</bookmark>;
    }

    public function clone():Object
    {
        return new Bookmark(name, xmin, ymin, xmax, ymax);
    }
}

}
