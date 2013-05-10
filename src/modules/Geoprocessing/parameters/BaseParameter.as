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

[Bindable]
public class BaseParameter implements IGPParameter
{
    private var _label:String;

    public function get label():String
    {
        return _label;
    }

    public function set label(value:String):void
    {
        _label = value;
    }

    private var _name:String;

    public function get name():String
    {
        return _name;
    }

    public function set name(value:String):void
    {
        _name = value;
    }

    private var _type:String;

    public function get type():String
    {
        return _type;
    }

    private var _direction:String;

    public function get direction():String
    {
        return _direction;
    }

    public function set direction(value:String):void
    {
        _direction = value;
    }

    private var _defaultValue:Object;

    public function get defaultValue():Object
    {
        return _defaultValue;
    }

    public function set defaultValue(value:Object):void
    {
        _defaultValue = value;
    }

    private var _choiceList:Array;

    public function get choiceList():Array
    {
        return _choiceList;
    }

    public function set choiceList(value:Array):void
    {
        _choiceList = value;
    }

    private var _toolTip:String;

    public function get toolTip():String
    {
        return _toolTip;
    }

    public function set toolTip(value:String):void
    {
        _toolTip = value;
    }

    private var _visible:Boolean = true;

    public function get visible():Boolean
    {
        return _visible;
    }

    public function set visible(value:Boolean):void
    {
        _visible = value;
    }

    private var _required:Boolean;

    public function get required():Boolean
    {
        return _required;
    }

    public function set required(value:Boolean):void
    {
        _required = value;
    }

    /**
     * Extending classes should override this method if value cannot be casted from String.
     */
    public function defaultValueFromString(text:String):void
    {
        defaultValue = text;
    }

    public function toXML():XML
    {
        var paramXML:XML = <param/>

        paramXML.@type = type;
        paramXML.@name = name;
        paramXML.@required = required;
        paramXML.@visible = visible;

        if (label)
        {
            paramXML.@label = label;
        }

        if (choiceList && choiceList.length > 0)
        {
            paramXML.appendChild(getChoiceListXML());
        }

        if (defaultValue)
        {
            paramXML.@defaultvalue = defaultValue;
        }

        if (toolTip)
        {
            paramXML.@tooltip = toolTip;
        }

        return paramXML;
    }

    protected function getChoiceListXML():XML
    {
        var choiceListXML:XML = <choicelist></choicelist>;
        var choiceXML:XML;
        for each (var choice:String in choiceList)
        {
            choiceXML = <choice/>;
            choiceXML.@value = choice;
            choiceListXML.appendChild(choiceXML);
        }

        return choiceListXML;
    }

    public function createInputEditorView():IVisualElement
    {
        throw new Error("Extending classes should implement method.");
    }

    public function createOutputEditorView():IVisualElement
    {
        throw new Error("Extending classes should implement method.");
    }
}

}
