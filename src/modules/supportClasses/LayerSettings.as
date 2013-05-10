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
package modules.supportClasses
{

[Bindable]
public class LayerSettings
{
    public var name:String;
    public var fields:Array = [];

    //preserve
    private var showObjectId:XML;
    private var showGlobalId:XML;
    private var exportLocation:XML;
    private var showAttachments:XML;
    private var showRelatedRecords:XML;
    private var columnsOrder:XML;
    private var sublayer:XML;

    public function fromXML(layerSettingsXML:XML):void
    {
        name = layerSettingsXML.@name[0];

        var parsedFieldSettings:FieldSettings;
        for each (var fieldXML:XML in layerSettingsXML.fields.field)
        {
            parsedFieldSettings = new FieldSettings();
            parsedFieldSettings.fromXML(fieldXML);
            if (parsedFieldSettings.name)
            {
                fields.push(parsedFieldSettings);
            }
        }

        showObjectId = layerSettingsXML.showobjectid[0];
        showGlobalId = layerSettingsXML.showglobalid[0];
        exportLocation = layerSettingsXML.exportlocation[0];
        showAttachments = layerSettingsXML.showattachments[0];
        showRelatedRecords = layerSettingsXML.showrelatedrecords[0];
        columnsOrder = layerSettingsXML.columnsorder[0];
        sublayer = layerSettingsXML.sublayer[0];
    }

    public function toXML():XML
    {
        var configXML:XML = <layer name={name}/>;
        if (fields && fields.length > 0)
        {
            var fieldsXML:XML = <fields/>;
            var fieldXML:XML;
            for each (var field:FieldSettings in fields)
            {
                fieldXML = <field name={field.name}/>;
                if (field.alias)
                {
                    fieldXML.@alias = field.alias;
                }
                if (field.tooltip)
                {
                    fieldXML.@tooltip = field.tooltip;
                }

                fieldsXML.appendChild(fieldXML);
            }

            if (fieldsXML.children().length() > 0)
            {
                configXML.appendChild(fieldsXML);
            }
        }

        if (showObjectId)
        {
            configXML.appendChild(showObjectId);

        }
        if (showGlobalId)
        {
            configXML.appendChild(showGlobalId);
        }
        if (exportLocation)
        {
            configXML.appendChild(exportLocation);
        }
        if (showAttachments)
        {
            configXML.appendChild(showAttachments);
        }
        if (showRelatedRecords)
        {
            configXML.appendChild(showRelatedRecords);
        }
        if (columnsOrder)
        {
            configXML.appendChild(columnsOrder);
        }
        if (sublayer)
        {
            configXML.appendChild(sublayer);
        }

        return configXML;
    }
}
}
