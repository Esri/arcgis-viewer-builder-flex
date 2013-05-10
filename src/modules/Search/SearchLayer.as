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
package modules.Search
{

import com.esri.ags.layers.supportClasses.Field;
import com.esri.builder.supportClasses.URLUtil;

import modules.supportClasses.OrderByFieldDirection;

import mx.collections.ArrayList;

[Bindable]
public class SearchLayer
{
    private var _url:String;

    public function get url():String
    {
        return _url;
    }

    public function set url(value:String):void
    {
        _url = URLUtil.encode(value);
    }

    public var name:String;
    public var useProxy:Boolean;
    public var titleField:String;
    public var expression:String;
    public var fields:ArrayList;
    public var textSearchLabel:String;
    public var orderByField:String;
    public var orderByFieldDirection:String;

    private var _orderByFields:Array;

    private function get orderByFields():Array
    {
        return _orderByFields;
    }

    private function set orderByFields(value:Array):void
    {
        _orderByFields = value;
        if (_orderByFields && _orderByFields.length > 0)
        {
            var fieldAndDirection:Array = _orderByFields[0].split(" ");
            orderByField = fieldAndDirection[0];
            orderByFieldDirection = fieldAndDirection.length > 1 ? fieldAndDirection[1] : OrderByFieldDirection.ASCENDING;
        }
    }

    public function SearchLayer()
    {
        fields = new ArrayList();
    }

    public function fromXML(searchLayerXML:XML):void
    {
        name = searchLayerXML.name;
        url = searchLayerXML.url;
        expression = searchLayerXML.expression;
        textSearchLabel = searchLayerXML.textsearchlabel;
        titleField = searchLayerXML.titlefield;
        useProxy = searchLayerXML.useproxy == 'true';

        if (searchLayerXML.orderbyfields[0])
        {
            orderByFields = searchLayerXML.orderbyfields[0].split(",");
        }

        importFieldsXML(searchLayerXML.fields.field);
    }

    private function importFieldsXML(fieldsXMLList:XMLList):void
    {
        var field:Field;
        for each (var fieldXML:XML in fieldsXMLList)
        {
            field = new Field();
            field.name = fieldXML.@name;
            if (fieldXML.@alias)
            {
                field.alias = fieldXML.@alias;
            }
            fields.addItem(field);
        }
    }

    public function toXML():XML
    {
        const searchLayerXML:XML = <layer/>;

        if (name)
        {
            searchLayerXML.appendChild(<name>{name}</name>);
        }

        if (url)
        {
            searchLayerXML.appendChild(<url>{url}</url>);
        }

        if (expression)
        {
            searchLayerXML.appendChild(<expression>{expression}</expression>);
        }

        if (textSearchLabel)
        {
            searchLayerXML.appendChild(<textsearchlabel>{textSearchLabel}</textsearchlabel>);
        }

        if (titleField)
        {
            searchLayerXML.appendChild(<titlefield>{titleField}</titlefield>);
        }

        if (fields.length)
        {
            searchLayerXML.appendChild(exportFieldsXML());
        }
        else
        {
            searchLayerXML.appendChild(<fields all="true"/>);
        }

        if (useProxy)
        {
            searchLayerXML.appendChild(<useproxy>true</useproxy>);
        }

        if (orderByField)
        {
            searchLayerXML.appendChild(<orderbyfields>{orderByField + " " + orderByFieldDirection}</orderbyfields>);
        }

        return searchLayerXML;
    }

    private function exportFieldsXML():XML
    {
        var fieldsXML:XML = <fields/>;
        var fieldsSource:Array = fields.source;
        var fieldXML:XML;
        for each (var field:Field in fieldsSource)
        {
            fieldXML = <field/>;
            fieldXML.@name = field.name;
            if (field.alias)
            {
                fieldXML.@alias = field.alias;
            }
            fieldsXML.appendChild(fieldXML);
        }

        return fieldsXML;
    }
}
}
