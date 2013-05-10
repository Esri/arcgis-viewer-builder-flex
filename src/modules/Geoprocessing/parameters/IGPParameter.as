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
package modules.Geoprocessing.parameters
{

import mx.core.IVisualElement;

public interface IGPParameter
{
    function get name():String;
    function get label():String;
    function get type():String;
    function get defaultValue():Object;
    function get choiceList():Array;
    function get toolTip():String;
    function get visible():Boolean;
    function get required():Boolean;

    function set name(value:String):void;
    function set label(value:String):void;
    function set defaultValue(value:Object):void;
    function set choiceList(value:Array):void;
    function set toolTip(value:String):void;
    function set visible(value:Boolean):void;
    function set required(value:Boolean):void;

    function createInputEditorView():IVisualElement
    function createOutputEditorView():IVisualElement
    function defaultValueFromString(text:String):void;
    function toXML():XML;
}

}
