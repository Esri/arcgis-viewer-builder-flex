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
package modules.Chart
{

import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.ags.portal.supportClasses.PopUpMediaInfo;

import modules.IWidgetModel;

import mx.collections.ArrayList;
import mx.resources.ResourceManager;

public final class ChartModel implements IWidgetModel
{
    [Bindable]
    public var chartLayerDefinitions:ArrayList = new ArrayList();
    [Bindable]
    public var highlightColor:uint = 0x336699;
    [Bindable]
    public var layerSelectionLabel:String = ResourceManager.getInstance().getString('BuilderStrings', 'chart.selectLayer');
    [Bindable]
    public var drawToolMenuLabel:String = ResourceManager.getInstance().getString('BuilderStrings', 'chart.selectDrawTool');

    public function importXML(doc:XML):void
    {
        highlightColor = doc.highlightcolor[0];
        if (doc.labels[0])
        {
            if (doc.labels.layerselectionlabel[0])
            {
                layerSelectionLabel = doc.labels.layerselectionlabel[0];
            }
            if (doc.labels.drawtoolmenulabel[0])
            {
                drawToolMenuLabel = doc.labels.drawtoolmenulabel[0];
            }
        }
        if (doc.layers[0])
        {
            chartLayerDefinitions = parseChartLayerDefinitionsXML(doc.layers[0]);
        }
    }

    private function parseChartLayerDefinitionsXML(layersXML:XML):ArrayList
    {
        var chartLayerDefinitions:ArrayList = new ArrayList();
        var chartLayerDefinition:ChartLayerDefinition;
        for each (var layerXML:XML in layersXML.layer)
        {
            chartLayerDefinition = new ChartLayerDefinition();
            chartLayerDefinition.label = layerXML.@label;
            chartLayerDefinition.url = layerXML.@url;
            chartLayerDefinition.labelField = layerXML.labelfield;
            chartLayerDefinition.fieldInfos = parseChartFieldsXML(layerXML.fields[0]);
            chartLayerDefinition.mediaInfos = parseChartMediasXML(layerXML.medias[0]);

            chartLayerDefinitions.addItem(chartLayerDefinition);
        }
        return chartLayerDefinitions;
    }


    public function parseChartFieldsXML(fieldsXML:XML):Array
    {
        var fields:Array = [];
        var field:PopUpFieldInfo;

        for each (var fieldXML:XML in fieldsXML.field)
        {
            field = new PopUpFieldInfo();
            field.fieldName = fieldXML.@name;
            fields.push(field);
        }

        return fields;
    }

    public function parseChartMediasXML(mediasXML:XML):Array
    {
        var medias:Array = [];
        var media:PopUpMediaInfo;

        for each (var mediaXML:XML in mediasXML.media)
        {
            media = new PopUpMediaInfo();
            media.caption = mediaXML.@caption;
            if (mediaXML.@chartfields[0])
            {
                media.chartFields = mediaXML.@chartfields.split(',');
                media.chartFields.splice(1); //only supports 1 field
            }
            media.chartNormalizationField = mediaXML.@chartnormalizationfield;
            media.imageLinkURL = mediaXML.@imagelinkurl;
            media.imageSourceURL = mediaXML.@imagesourceurl;
            media.title = mediaXML.@title;
            media.caption = mediaXML.@caption;
            media.type = mediaXML.@type;

            medias.push(media);
        }

        return medias;
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <highlightcolor>{highlightColor}</highlightcolor>
                <labels>
                    <layerselectionlabel>{layerSelectionLabel}</layerselectionlabel>
                    <drawtoolmenulabel>{drawToolMenuLabel}</drawtoolmenulabel>
                </labels>
            </configuration>;
        if (chartLayerDefinitions.length > 0)
        {
            configXML.appendChild(getChartLayerDefinitionsXML());
        }
        return configXML;
    }

    private function getChartLayerDefinitionsXML():XML
    {
        var chartLayerDefinitionsXML:XML = <layers/>;
        var chartLayerDefinitionsSource:Array = chartLayerDefinitions.source;
        var chartLayerDefinitionXML:XML;
        for each (var chartLayerDefinition:ChartLayerDefinition in chartLayerDefinitionsSource)
        {
            chartLayerDefinitionXML =
                <layer>
                    <labelfield>{chartLayerDefinition.labelField}</labelfield>
                </layer>;
            chartLayerDefinitionXML.@label = chartLayerDefinition.label;
            if (chartLayerDefinition.url)
            {
                chartLayerDefinitionXML.@url = chartLayerDefinition.url;
            }
            chartLayerDefinitionXML.appendChild(getChartFieldsXML(chartLayerDefinition.fieldInfos));
            chartLayerDefinitionXML.appendChild(getChartMediasXML(chartLayerDefinition.mediaInfos));
            chartLayerDefinitionsXML.appendChild(chartLayerDefinitionXML);
        }

        return chartLayerDefinitionsXML;
    }

    private function getChartFieldsXML(fieldInfos:Array):XML
    {
        var chartFieldsXML:XML = <fields/>;
        var chartFieldXML:XML;
        for each (var fieldInfo:PopUpFieldInfo in fieldInfos)
        {
            chartFieldXML = <field/>;
            chartFieldXML.@name = fieldInfo.fieldName;
            chartFieldsXML.appendChild(chartFieldXML);
        }

        return chartFieldsXML;
    }

    private function getChartMediasXML(mediaInfos:Array):XML
    {
        var chartMediasXML:XML = <medias/>;
        var chartMediaXML:XML;
        for each (var mediaInfo:PopUpMediaInfo in mediaInfos)
        {
            chartMediaXML = <media/>;
            chartMediaXML.@chartfields = mediaInfo.chartFields[0]; //only supports 1 field
            chartMediaXML.@title = mediaInfo.title;
            if (mediaInfo.caption)
            {
                chartMediaXML.@caption = mediaInfo.caption;
            }
            chartMediaXML.@type = mediaInfo.type;
            chartMediasXML.appendChild(chartMediaXML);
        }

        return chartMediasXML;
    }
}
}
