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
package modules.Draw
{

import modules.IWidgetModel;

import mx.collections.ArrayList;
import mx.resources.ResourceManager;

internal final class DrawModel implements IWidgetModel
{
    [Bindable]
    public var distUnitList:ArrayList = new ArrayList();
    [Bindable]
    public var areaUnitList:ArrayList = new ArrayList();

    public function importXML(doc:XML):void
    {
        parseDistanceUnits(doc.distanceunits.distanceunit);
        parseAreaUnits(doc.areaunits.areaunit);
    }

    private function parseDistanceUnits(distanceUnitsXML:XMLList):void
    {
        for each (var distanceUnitXML:XML in distanceUnitsXML)
        {
            distUnitList.addItem(createDistanceMeasurementUnit(distanceUnitXML));
        }
    }

    private function createDistanceMeasurementUnit(distanceUnitXML:XML):DistanceMeasurementUnit
    {
        if (distanceUnitXML.@id[0])
        {
            return createDistanceMeasurementUnitFromId(distanceUnitXML.@id[0]);
        }
        else
        {
            return new DistanceMeasurementUnit(distanceUnitXML, distanceUnitXML.@abbr, distanceUnitXML.@conversion);
        }
    }

    private function createDistanceMeasurementUnitFromId(id:String):DistanceMeasurementUnit
    {
        var unitLabel:String;
        var unitAbbreviation:String;
        var unitConversion:Number;

        switch (id)
        {
            case "ft":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.feet");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", 'units.feetAbbr');
                unitConversion = 3.2808;
                break;
            }
            case "km":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.kilometers");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.kilometersAbbr");
                unitConversion = 0.001;
                break;
            }
            case "m":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.meters");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.metersAbbr");
                unitConversion = 1;
                break;
            }
            case "mi":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.miles");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.milesAbbr");
                unitConversion = 0.000621;
                break;
            }
            case "yd":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", 'units.yards');
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", 'units.yardsAbbr');
                unitConversion = 1.0936133;
                break;
            }
        }

        return new DistanceMeasurementUnit(unitLabel, unitAbbreviation, unitConversion);
    }

    private function parseAreaUnits(areaUnitsXML:XMLList):void
    {
        for each (var areaUnitXML:XML in areaUnitsXML)
        {
            areaUnitList.addItem(createAreaMeasurementUnit(areaUnitXML));
        }
    }

    private function createAreaMeasurementUnit(areaUnitXML:XML):AreaMeasurementUnit
    {
        if (areaUnitXML.@id[0])
        {
            return createAreaMeasurementUnitFromId(areaUnitXML.@id[0]);
        }
        else
        {
            return new AreaMeasurementUnit(areaUnitXML, areaUnitXML.@abbr, areaUnitXML.@conversion);
        }
    }

    private function createAreaMeasurementUnitFromId(id:String):AreaMeasurementUnit
    {
        var unitLabel:String;
        var unitAbbreviation:String;
        var unitConversion:Number;

        switch (id)
        {
            case "ac":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.acres");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.acresAbbr");
                unitConversion = 0.00024710538147;
                break;
            }
            case "ha":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.hectares");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.hectaresAbbr");
                unitConversion = 0.0001;
                break;
            }
            case "sq ft":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.squareFeet");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.squareFeetAbbr");
                unitConversion = 10.763910417;
                break;
            }
            case "sq km":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.squareKilometers");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.squareKilometersAbbr");
                unitConversion = 0.000001;
                break;
            }
            case "sq m":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.squareMeters");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.squareMetersAbbr");
                unitConversion = 1;
                break;
            }
            case "sq mi":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.squareMiles");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.squareMilesAbbr");
                unitConversion = 0.0000003861021;
                break;
            }
            case "sq yd":
            {
                unitLabel = ResourceManager.getInstance().getString("BuilderStrings", "units.squareYards");
                unitAbbreviation = ResourceManager.getInstance().getString("BuilderStrings", "units.squareYardsAbbr");
                unitConversion = 1.19599005;
                break;
            }
        }

        return new AreaMeasurementUnit(unitLabel, unitAbbreviation, unitConversion);
    }

    public function exportXML():XML
    {
        const configXML:XML = <configuration/>;
        if (distUnitList.length)
        {
            configXML.appendChild(getDistanceUnitsXML());
        }
        if (areaUnitList.length)
        {
            configXML.appendChild(getAreaUnitsXML());
        }
        return configXML;
    }

    private function getDistanceUnitsXML():XML
    {
        var distanceUnitListSource:Array = distUnitList.source;
        var distanceUnitsXML:XML = <distanceunits/>;
        for each (var distanceUnit:DistanceMeasurementUnit in distanceUnitListSource)
        {
            distanceUnitsXML.appendChild(distanceUnit.toXML());
        }
        return distanceUnitsXML;
    }

    private function getAreaUnitsXML():XML
    {
        var areaUnitListSource:Array = areaUnitList.source;
        var areaUnitsXML:XML = <areaunits/>;
        for each (var areaUnit:AreaMeasurementUnit in areaUnitListSource)
        {
            areaUnitsXML.appendChild(areaUnit.toXML());
        }
        return areaUnitsXML;
    }
}
}
