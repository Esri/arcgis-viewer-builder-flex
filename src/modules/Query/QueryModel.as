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
package modules.Query
{

import com.esri.ags.layers.supportClasses.Field;
import com.esri.builder.supportClasses.URLUtil;

import modules.IWidgetModel;
import modules.supportClasses.NoneOptionArrayList;
import modules.supportClasses.OrderByFieldDirection;

import mx.collections.ArrayList;

[Bindable]
public final class QueryModel implements IWidgetModel
{

    public var query:String = '';
    public var titleField:String = '';
    public var linkField:String = '';
    public var filterField:Object;
    public var refreshRate:String = '';
    public var zoomScale:String = '';
    public var fields:ArrayList = new ArrayList() /*<Field>*/;
    public var names:NoneOptionArrayList = new NoneOptionArrayList() /*<String>*/;
    public var useProxy:Boolean;
    public var shareResults:Boolean = false;

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

    private var _layer:String = '';

    public function get layer():String
    {
        return _layer;
    }

    public function set layer(value:String):void
    {
        _layer = URLUtil.encode(value);
    }

    public function importXML(doc:XML):void
    {
        layer = doc.layer;
        query = doc.query;
        titleField = doc.titlefield;
        linkField = doc.linkfield;
        refreshRate = doc.refreshrate;
        zoomScale = doc.zoomscale;
        useProxy = doc.useproxy == 'true';
        shareResults = doc.shareresults[0] == "true";

        if (doc.orderbyfields[0])
        {
            orderByFields = doc.orderbyfields[0].split(",");
        }

        for each (var fieldXML:XML in doc.fields.field)
        {
            const field:Field = new Field();
            field.name = fieldXML.@name;
            field.alias = fieldXML.@alias;
            fields.addItem(field);
            names.addItem(field.name);
        }
    }

    public function exportXML():XML
    {
        const configXML:XML = <configuration>
                <layer>{layer}</layer>
                <query>{query}</query>
                <titlefield>{titleField}</titlefield>
                <linkfield>{linkField}</linkfield>
                <refreshrate>{refreshRate}</refreshrate>
                <zoomscale>{zoomScale}</zoomscale>
                <!-- filterfield>
                    <name>region</name>
                    <alias>Filter by region (e.g., California )</alias>
                </filterfield -->
                <shareresults>{shareResults}</shareresults>
            </configuration>;

        if (orderByField)
        {
            configXML.appendChild(<orderbyfields>{orderByField + " " + orderByFieldDirection}</orderbyfields>);
        }

        if (fields && fields.length)
        {
            const fieldsXML:XML = <fields all='false'/>
            for each (var field:Field in fields.source)
            {
                const fieldXML:XML = <field name={field.name}/>;
                if (field.alias)
                {
                    fieldXML.@alias = field.alias;
                }
                fieldsXML.appendChild(fieldXML);
            }
            configXML.appendChild(fieldsXML);
        }
        else
        {
            configXML.appendChild(<fields all='true'/>);
        }

        if (useProxy)
        {
            configXML.appendChild(<useproxy>true</useproxy>);
        }
        return configXML;
    }
}
}
