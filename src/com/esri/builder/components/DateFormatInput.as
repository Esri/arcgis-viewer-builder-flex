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
package com.esri.builder.components
{

import flash.events.Event;

import mx.collections.ArrayList;

import spark.components.supportClasses.DropDownListBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.SkinnableTextBase;
import spark.events.IndexChangeEvent;
import spark.events.TextOperationEvent;

[SkinState("knownDateFormat")]
[SkinState("customDateFormat")]
public class DateFormatInput extends SkinnableComponent
{
    [SkinPart(required="true")]
    public var dateFormatSelection:DropDownListBase;
    [SkinPart(required="true")]
    public var customDateFormatInput:SkinnableTextBase;

    [Bindable]
    public var uniqueDateFormats:ArrayList;

    private var dateFormatSelectionChanged:Boolean;

    private var _dateFormat:String;

    [Bindable(event="dateFormatChanged")]
    public function get dateFormat():String
    {
        return _dateFormat;
    }

    public function set dateFormat(value:String):void
    {
        if (value && value != _dateFormat)
        {
            updateInternalDateFormat(value);
            dateFormatSelectionChanged = true;
            invalidateProperties();
        }
    }

    private function updateInternalDateFormat(dateFormat:String):void
    {
        _dateFormat = dateFormat;
        dispatchEvent(new Event("dateFormatChanged"));
    }

    override protected function commitProperties():void
    {
        if (dateFormatSelectionChanged)
        {
            dateFormatSelectionChanged = false;
            selectMatchingDateFormat();
        }

        super.commitProperties();
    }

    private function selectMatchingDateFormat():void
    {
        if (!dateFormatSelection)
        {
            return;
        }

        if (!dateFormat)
        {
            dateFormatSelection.selectedIndex = 0;
            updateDateFormat();
        }

        const dateFormatOptions:Array = uniqueDateFormats.source;
        var isDateFormatCustom:Boolean = true;
        for each (var dateFormatOption:String in dateFormatOptions)
        {
            if (dateFormatOption == dateFormat)
            {
                dateFormatSelection.selectedItem = _dateFormat;
                isDateFormatCustom = false;
                break;
            }
        }

        if (isDateFormatCustom)
        {
            dateFormatSelection.selectedIndex = dateFormatSelection.dataProvider.length - 1;
        }
    }

    public function DateFormatInput()
    {
        uniqueDateFormats = new ArrayList(getUniqueDateFormats());
    }

    private function getUniqueDateFormats():Array
    {
        var dateFormats:Array = [
            resourceManager.getString('BuilderStrings', 'time.dayShortMonthYear'),
            resourceManager.getString('BuilderStrings', 'time.longDate'),
            resourceManager.getString('BuilderStrings', 'time.longMonthDayYear'),
            resourceManager.getString('BuilderStrings', 'time.longMonthYear'),
            resourceManager.getString('BuilderStrings', 'time.shortDate'),
            resourceManager.getString('BuilderStrings', 'time.shortDateLongTime'),
            resourceManager.getString('BuilderStrings', 'time.shortDateLongTime24'),
            resourceManager.getString('BuilderStrings', 'time.shortDateShortTime'),
            resourceManager.getString('BuilderStrings', 'time.shortDateShortTime24'),
            resourceManager.getString('BuilderStrings', 'time.shortMonthYear'),
            resourceManager.getString('BuilderStrings', 'time.year'),
            resourceManager.getString('BuilderStrings', 'time.custom')];

        var uniqueDateFormats:Array = [];

        for each (var dateFormat:String in dateFormats)
        {
            if (uniqueDateFormats.indexOf(dateFormat) == -1)
            {
                uniqueDateFormats.push(dateFormat);
            }
        }

        return uniqueDateFormats;
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == dateFormatSelection)
        {
            dateFormatSelection.addEventListener(IndexChangeEvent.CHANGE, dateFormatSelection_changeHandler, false, 0, true);
            dateFormatSelectionChanged = true;
            invalidateProperties();
        }
        else if (instance == customDateFormatInput)
        {
            customDateFormatInput.addEventListener(TextOperationEvent.CHANGE, customDateFormatInput_changeHandler, false, 0, true);
        }

        super.partAdded(partName, instance);
    }

    private function dateFormatSelection_changeHandler(event:IndexChangeEvent):void
    {
        updateDateFormat();
        invalidateSkinState();
    }

    override protected function getCurrentSkinState():String
    {
        return dateFormatSelection
            && (dateFormatSelection.selectedIndex == uniqueDateFormats.length - 1) ?
            "customDateFormat" : "knownDateFormat";
    }

    private function updateDateFormat():void
    {
        const selectedDateFormat:String = dateFormatSelection.selectedItem;
        if (selectedDateFormat != resourceManager.getString('BuilderStrings', 'time.custom'))
        {
            updateInternalDateFormat(selectedDateFormat);
        }
    }

    private function customDateFormatInput_changeHandler(event:TextOperationEvent):void
    {
        updateInternalDateFormat(customDateFormatInput.text);
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == dateFormatSelection)
        {
            dateFormatSelection.removeEventListener(IndexChangeEvent.CHANGE, dateFormatSelection_changeHandler);
        }
        else if (instance == customDateFormatInput)
        {
            customDateFormatInput.removeEventListener(TextOperationEvent.CHANGE, customDateFormatInput_changeHandler);
        }

        super.partRemoved(partName, instance);
    }
}
}
