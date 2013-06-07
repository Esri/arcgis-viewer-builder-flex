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

import com.esri.ags.layers.supportClasses.Field;

public class FieldUtil
{
    public static function getValidFields(fields:Array):Array
    {
        return fields ? fields.filter(isValidField) : [];
    }

    private static function isValidField(field:Field, index:int, array:Array):Boolean
    {
        return isValidFieldName(field.name);
    }

    public static function isValidFieldName(fieldName:String):Boolean
    {
        const lowerCaseFieldName:String = fieldName ? fieldName.toLowerCase() : "";
        return !(lowerCaseFieldName == "objectid" || lowerCaseFieldName == "shape");
    }

    public static function findFieldByName(fields:Array, name:String):Field
    {
        var fieldToSelect:Field;

        if (fields && fields.length > 0)
        {
            for each (var field:Field in fields)
            {
                if (field.name == name)
                {
                    fieldToSelect = field;
                    break;
                }
            }
        }

        return fieldToSelect;
    }

    public static function getNumericFields(fields:Array):Array
    {
        var numericFields:Array = [];

        for each (var field:Field in fields)
        {
            if (isFieldNumeric(field))
            {
                numericFields.push(field);
            }
        }

        return numericFields;
    }

    public static function isFieldNumeric(field:Field):Boolean
    {
        return field.type == Field.TYPE_DOUBLE
            || field.type == Field.TYPE_INTEGER
            || field.type == Field.TYPE_SINGLE
            || field.type == Field.TYPE_SMALL_INTEGER;
    }
}
}
