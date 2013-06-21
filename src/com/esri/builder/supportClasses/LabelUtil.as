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
package com.esri.builder.supportClasses
{

import mx.core.FlexGlobals;
import mx.utils.StringUtil;

import spark.utils.LabelUtil;

public final class LabelUtil
{
    public static function findLongestLabelItem(items:Array,
                                                labelField:String = null,
                                                labelFunction:Function = null):Object
    {
        var longestItem:Object;

        var currentItemWidth:Number;
        var longestItemLabelWidth:Number = 0;
        var currentItemLabel:String;

        for each (var item:Object in items)
        {
            currentItemLabel = itemToLabel(item, labelField, labelFunction);

            currentItemWidth =
                FlexGlobals.topLevelApplication.measureText(currentItemLabel).width;

            if (currentItemWidth > longestItemLabelWidth)
            {
                longestItemLabelWidth = currentItemWidth;
                longestItem = item;
            }
        }

        return longestItem;
    }

    private static function itemToLabel(item:Object,
                                        labelField:String = null,
                                        labelFunction:Function = null):String
    {
        return spark.utils.LabelUtil.itemToLabel(item, labelField, labelFunction);
    }

    public static function generateUniqueLabel(fileNameTemplate:String, usedNames:Array, isUniqueFunction:Function = null):String
    {
        var currentID:int = 1;
        var uniqueLabel:String;

        var uniquenessFunction:Function =
            isUniqueFunction != null ? isUniqueFunction : isNameUnique;

        do
        {
            uniqueLabel = StringUtil.substitute(fileNameTemplate, currentID++);
        } while (!uniquenessFunction(uniqueLabel, usedNames));

        return uniqueLabel;
    }

    private static function isNameUnique(name:String, usedNames:Array):Boolean
    {
        return usedNames.indexOf(name) == -1;
    }
}
}
