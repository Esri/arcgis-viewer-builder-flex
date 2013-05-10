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
package modules.Time
{

import modules.IWidgetModel;

public class TimeModel implements IWidgetModel
{
    public static const YEARS:String = "years";
    public static const MONTHS:String = "months";
    public static const DAYS:String = "days";
    public static const HOURS:String = "hours";
    public static const MINUTES:String = "minutes";
    public static const SECONDS:String = "seconds";

    private const EXPORT_DATE_FORMAT:String = "YYYY/MM/DD";

    [Bindable]
    public var dateFormat:String = "MMM D YYYY";
    [Bindable]
    public var loop:Boolean = false;
    [Bindable]
    public var willSetFromLayer:Boolean = true;
    [Bindable]
    public var setFromLayer:String = "";
    [Bindable]
    public var singleThumbAsTimeInstant:Boolean = false;
    [Bindable]
    public var thumbCount:int = 1;
    [Bindable]
    public var thumbMovingRate:int = 1000;
    [Bindable]
    public var startTime:Date = new Date();
    [Bindable]
    public var endTime:Date = new Date();
    [Bindable]
    public var timeStopsInterval:int;
    [Bindable]
    public var timeStopsUnits:String;
    [Bindable]
    public var willUseTimeStopsCount:Boolean = true;
    [Bindable]
    public var timeStopsCount:int = 10;

    public function importXML(doc:XML):void
    {
        if (doc.dateformat[0])
        {
            dateFormat = doc.dateformat[0];
        }

        loop = (doc.loop[0] == "true");
        singleThumbAsTimeInstant = (doc.singlethumbastimeinstant[0] == "true");

        if (doc.thumbcount[0])
        {
            const parsedThumbCount:int = parseInt(doc.thumbcount[0]);
            if (!isNaN(parsedThumbCount))
            {
                thumbCount = parsedThumbCount;
            }
        }

        if (doc.thumbmovingrate[0])
        {
            const parsedThumbMovingRate:int = parseInt(doc.thumbmovingrate[0]);
            if (!isNaN(parsedThumbMovingRate))
            {
                thumbMovingRate = parsedThumbMovingRate;
            }
        }

        if (doc.timeextent.starttime[0]
            && doc.timeextent.endtime[0])
        {
            const parsedStartTime:Number = Date.parse(doc.timeextent.starttime[0]);
            if (!isNaN(parsedStartTime))
            {
                startTime = new Date(parsedStartTime);
            }

            const parsedEndTime:Number = Date.parse(doc.timeextent.endtime[0]);
            if (!isNaN(parsedEndTime))
            {
                endTime = new Date(parsedEndTime);
            }
        }
        if (doc.timestops[0])
        {
            if (doc.timestops.timestopscount[0])
            {
                timeStopsCount = doc.timestops.timestopscount;
            }
            else
            {
                timeStopsInterval = doc.timestops.timestopsinterval;
                timeStopsUnits = doc.timestops.timestopsunits;
                willUseTimeStopsCount = false;
            }
        }

        if (doc.timeextent.@setfromlayer[0])
        {
            setFromLayer = doc.timeextent.@setfromlayer[0];
            willSetFromLayer = true;
        }
        else
        {
            willSetFromLayer = false;
        }
    }

    public function exportXML():XML
    {
        const configXML:XML = <configuration>
                <dateformat>{dateFormat}</dateformat>
                <loop>{loop}</loop>
                <singlethumbastimeinstant>{singleThumbAsTimeInstant}</singlethumbastimeinstant>
                <thumbcount>{thumbCount}</thumbcount>
                <thumbmovingrate>{thumbMovingRate}</thumbmovingrate>
            </configuration>;

        configXML.appendChild(getTimeExtentXML());
        configXML.appendChild(getTimeStopsXML());
        return configXML;
    }

    private function getTimeExtentXML():XML
    {
        const timeExtentXML:XML = <timeextent/>;

        if (willSetFromLayer)
        {
            timeExtentXML.@setfromlayer = setFromLayer;
        }
        else
        {
            appendStartAndEndTimes(timeExtentXML);
        }

        return timeExtentXML;
    }

    private function appendStartAndEndTimes(timeExtentXML:XML):void
    {
        const startTimeXML:XML = <starttime>{startTime.toString()}</starttime>;
        const endTimeXML:XML = <endtime>{endTime.toString()}</endtime>;
        timeExtentXML.appendChild(startTimeXML);
        timeExtentXML.appendChild(endTimeXML);
    }

    private function getTimeStopsXML():XML
    {
        const timeStopsXML:XML = <timestops/>;
        if (willUseTimeStopsCount)
        {
            timeStopsXML.appendChild(<timestopscount>{timeStopsCount}</timestopscount>);
        }
        else
        {
            timeStopsXML.appendChild(<timestopsinterval>{timeStopsInterval}</timestopsinterval>);
            timeStopsXML.appendChild(<timestopsunits>{timeStopsUnits}</timestopsunits>);
        }
        return timeStopsXML;
    }
}
}
