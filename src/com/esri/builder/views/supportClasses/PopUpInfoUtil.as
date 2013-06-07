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
package com.esri.builder.views.supportClasses
{

import com.esri.ags.layers.supportClasses.Field;
import com.esri.ags.portal.supportClasses.PopUpFieldFormat;
import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.ags.portal.supportClasses.PopUpMediaInfo;

public final class PopUpInfoUtil
{
    public static function popUpFieldInfosFromXML(fieldsXML:XMLList):Array
    {
        var fields:Array = [];

        for each (var fieldXML:XML in fieldsXML)
        {
            fields.push(popUpFieldInfoFromXML(fieldXML));
        }

        return fields;
    }

    public static function popUpFieldInfoFromXML(fieldXML:XML):PopUpFieldInfo
    {
        var popUpFieldInfo:PopUpFieldInfo = new PopUpFieldInfo();

        popUpFieldInfo.fieldName = fieldXML.@name;
        popUpFieldInfo.label = (fieldXML.@alias[0]) ? fieldXML.@alias : fieldXML.@name;
        popUpFieldInfo.visible = (fieldXML.@visible[0] == "true");
        if (fieldXML.format[0])
        {
            popUpFieldInfo.format = popUpFieldFormatFromXML(fieldXML.format[0]);
        }

        return popUpFieldInfo;
    }

    public static function popUpFieldFormatFromXML(formatXML:XML):PopUpFieldFormat
    {
        var popUpFieldFormat:PopUpFieldFormat = new PopUpFieldFormat();

        if (formatXML.@dateformat[0])
        {
            popUpFieldFormat.dateFormat = formatXML.@dateformat;
        }
        popUpFieldFormat.precision = formatXML.@precision[0] ? formatXML.@precision : -1;
        popUpFieldFormat.useThousandsSeparator = (formatXML.@usethousandsseparator == "true");
        popUpFieldFormat.useUTC = (formatXML.@useutc == "true");

        return popUpFieldFormat;
    }

    public static function popUpMediaInfosFromXML(mediasXML:XMLList):Array
    {
        var medias:Array = [];

        for each (var mediaXML:XML in mediasXML)
        {
            medias.push(popUpMediaInfoFromXML(mediaXML));
        }

        return medias;
    }

    public static function popUpMediaInfoFromXML(mediaXML:XML):PopUpMediaInfo
    {
        var popUpMediaInfo:PopUpMediaInfo = new PopUpMediaInfo();

        popUpMediaInfo.type = mediaXML.@type;
        popUpMediaInfo.title = mediaXML.@title;
        popUpMediaInfo.caption = mediaXML.@caption;
        popUpMediaInfo.imageLinkURL = mediaXML.@imagelink;
        popUpMediaInfo.imageSourceURL = mediaXML.@imagesource;
        if (mediaXML.@chartfields[0])
        {
            popUpMediaInfo.chartFields = mediaXML.@chartfields.split(',');
        }
        popUpMediaInfo.chartNormalizationField = mediaXML.@chartnormalizationfield;

        return popUpMediaInfo;
    }

    public static function popUpMediaInfosToXML(medias:Array):XML
    {
        var mediasXML:XML = <medias/>;

        var mediaXML:XML;
        for each (var popUpMediaInfo:PopUpMediaInfo in medias)
        {
            mediaXML = <media/>;

            if (popUpMediaInfo.type)
            {
                mediaXML.@type = popUpMediaInfo.type;
            }
            if (popUpMediaInfo.title)
            {
                mediaXML.@title = popUpMediaInfo.title;
            }
            if (popUpMediaInfo.caption)
            {
                mediaXML.@caption = popUpMediaInfo.caption;
            }
            if (popUpMediaInfo.imageLinkURL)
            {
                mediaXML.@imagelink = popUpMediaInfo.imageLinkURL;
            }
            if (popUpMediaInfo.imageSourceURL)
            {
                mediaXML.@imagesource = popUpMediaInfo.imageSourceURL;
            }
            if (popUpMediaInfo.chartFields)
            {
                mediaXML.@chartfields = popUpMediaInfo.chartFields;
            }

            mediasXML.appendChild(mediaXML);
        }

        return mediasXML;
    }

    public static function popUpFieldInfosToXML(fields:Array):XML
    {
        var fieldsXML:XML = <fields/>;

        var fieldXML:XML;
        for each (var popUpFieldInfo:PopUpFieldInfo in fields)
        {
            fieldXML = <field/>;

            if (popUpFieldInfo.fieldName)
            {
                fieldXML.@name = popUpFieldInfo.fieldName;
            }
            if (popUpFieldInfo.label)
            {
                fieldXML.@alias = popUpFieldInfo.label;
            }
            if (popUpFieldInfo.visible)
            {
                fieldXML.@visible = popUpFieldInfo.visible;
            }
            if (popUpFieldInfo.format)
            {
                fieldXML.appendChild(popUpFieldFormatToXML(popUpFieldInfo.format));
            }

            fieldsXML.appendChild(fieldXML);
        }

        return fieldsXML;
    }

    public static function popUpFieldFormatToXML(format:PopUpFieldFormat):XML
    {
        var formatXML:XML = <format precision={format.precision}
                usethousandsseparator={format.useThousandsSeparator}
                useutc={format.useUTC}/>;

        var dateFormat:String = format.dateFormat;
        if (dateFormat)
        {
            formatXML.@dateformat = dateFormat;
        }

        return formatXML;
    }

    public static function popUpFieldInfosFromFields(fields:Array):Array
    {
        var popUpFieldInfos:Array = [];

        var popUpFieldInfo:PopUpFieldInfo;
        for each (var field:Field in fields)
        {
            popUpFieldInfo = new PopUpFieldInfo();
            popUpFieldInfo.fieldName = field.name;
            popUpFieldInfo.label = field.alias;

            popUpFieldInfos.push(popUpFieldInfo);
        }

        return popUpFieldInfos;
    }
}
}
