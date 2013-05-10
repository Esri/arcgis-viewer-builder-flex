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
package modules.Coordinate
{

import modules.IWidgetModel;

public class CoordinateModel implements IWidgetModel
{
    public static const GEOGRAPHIC:String = 'geo';
    public static const DMS:String = 'dms';
    public static const WEB_MERCATOR:String = 'mercator';
    public static const DEFAULT_FONT_SIZE:Number = 9;

    private var template:String;
    private var fontFamily:String;
    private var fontColor:String;
    [Bindable]
    public var fontSize:Number = DEFAULT_FONT_SIZE;
    private var fontWeight:String;

    [Bindable]
    public var outputUnit:String = GEOGRAPHIC;

    public function importXML(doc:XML):void
    {
        parseLabels(doc);
        outputUnit = parseOutputUnit(doc.outputunit[0]);
    }

    private function parseLabels(doc:XML):void
    {
        var parsedTemplate:String = doc.labels.template[0] || doc.label.@template[0];
        var parsedFontColor:String = doc.labelstyle.@color[0] || doc.label.@color[0];
        var parsedFontFamily:String = doc.labelstyle.@fontfamily[0] || doc.label.@fontfamily[0];
        var parsedFontSize:Number = parseFloat(doc.labelstyle.@fontsize[0] || doc.label.@fontsize[0]);
        var parsedFontWeight:String = doc.labelstyle.@fontweight[0] || doc.label.@fontweight[0];

        if (parsedTemplate)
        {
            template = parsedTemplate;
        }
        if (parsedFontColor)
        {
            fontColor = parsedFontColor;
        }
        if (parsedFontFamily)
        {
            fontFamily = parsedFontFamily;
        }
        if (!isNaN(parsedFontSize))
        {
            fontSize = parsedFontSize;
        }
        if (parsedFontWeight)
        {
            fontWeight = parsedFontWeight;
        }
    }

    private function parseOutputUnit(unit:String):String
    {
        var parsedOutputUnit:String = unit;

        switch (unit)
        {
            case GEOGRAPHIC:
            case DMS:
            case WEB_MERCATOR:
                break;
            default:
            {
                parsedOutputUnit = GEOGRAPHIC;
            }
        }

        return parsedOutputUnit;
    }

    public function exportXML():XML
    {
        const configXML:XML =
            <configuration>
                <outputunit>{outputUnit}</outputunit>
            </configuration>;

        appendLabels(configXML);

        return configXML;
    }

    private function appendLabels(configXML:XML):void
    {
        var labelsXML:XML = <labels/>

        if (template)
        {
            labelsXML.appendChild(<template>{template}</template>);
        }

        if (labelsXML.children().length() > 0)
        {
            configXML.appendChild(labelsXML);
        }

        var labelStyleXML:XML = <labelstyle/>

        if (fontColor)
        {
            labelStyleXML.@color = fontColor;
        }
        if (fontFamily)
        {
            labelStyleXML.@fontfamily = fontFamily;
        }
        if (!isNaN(fontSize))
        {
            labelStyleXML.@fontsize = fontSize;
        }
        if (fontWeight)
        {
            labelStyleXML.@fontweight = fontWeight;
        }

        if (labelStyleXML.attributes().length() > 0)
        {
            configXML.appendChild(labelStyleXML);
        }
    }
}
}
