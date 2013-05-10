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
package com.esri.builder.model
{

import com.esri.ags.portal.supportClasses.PopUpFieldInfo;
import com.esri.builder.supportClasses.XMLUtil;
import com.esri.builder.views.supportClasses.PopUpInfoUtil;

import mx.collections.ArrayList;

public class PopUpConfig
{
    [Bindable]
    public var title:String = "";
    [Bindable]
    public var description:String = "";
    [Bindable]
    public var mediaInfos:ArrayList = new ArrayList();
    [Bindable]
    public var fieldInfos:ArrayList = new ArrayList();
    [Bindable]
    public var showAttachments:Boolean = false;
    [Bindable]
    public var showRelatedRecords:Boolean = false;

    public function exportXML():XML
    {
        const configXML:XML = <configuration/>;

        if (title != "")
        {
            configXML.appendChild(<title>{title}</title>);
        }

        if (description)
        {
            configXML.appendChild(<description>{XMLUtil.wrapInCDATA(description)}</description>);
            hideFieldInfos();
        }

        configXML.appendChild(PopUpInfoUtil.popUpFieldInfosToXML(fieldInfos.toArray()));

        if (mediaInfos.length > 0)
        {
            configXML.appendChild(PopUpInfoUtil.popUpMediaInfosToXML(mediaInfos.toArray()));
        }

        configXML.appendChild(<showattachments>{showAttachments}</showattachments>);
        configXML.appendChild(<showrelatedrecords>{showRelatedRecords}</showrelatedrecords>);

        return configXML;
    }

    private function hideFieldInfos():void
    {
        var fieldInfosSource:Array = fieldInfos.source;
        for each (var fieldInfo:PopUpFieldInfo in fieldInfosSource)
        {
            fieldInfo.visible = false;
        }
    }

    public function importXML(configXML:XML, fieldsToMerge:Array):void
    {
        if (!configXML)
        {
            return;
        }

        title = configXML.title;

        fieldInfos.source = PopUpInfoUtil.popUpFieldInfosFromFields(fieldsToMerge);

        if (configXML.fields.field.length() > 0)
        {
            const fieldsXMLWithName:XMLList =
                configXML.fields.field.(attribute("@name") != null);

            fieldInfos.source = mergePopUpFieldInfosByUniqueFieldName(PopUpInfoUtil.popUpFieldInfosFromXML(fieldsXMLWithName),
                                                                      fieldInfos.source);
        }

        if (configXML.description[0])
        {
            description = configXML.description;
            hideFieldInfos();
        }

        if (configXML.medias.media.length() > 0)
        {
            const mediasXMLWithTypeAndTitle:XMLList =
                configXML.medias.media.(attribute("type") != null && attribute("title") != null);

            mediaInfos.source = PopUpInfoUtil.popUpMediaInfosFromXML(mediasXMLWithTypeAndTitle);
        }

        showAttachments = configXML.showattachments[0] == "true";
        showRelatedRecords = configXML.showrelatedrecords[0] == "true";
    }

    //TODO: optimize
    private function mergePopUpFieldInfosByUniqueFieldName(primaryPopUpFieldInfos:Array, secondaryPopUpFieldInfos:Array):Array
    {
        const mergedPopUpFieldInfos:Array = primaryPopUpFieldInfos.concat();

        const priorityFieldNames:Array = [];
        for each (var priorityPopUpFieldInfo:PopUpFieldInfo in mergedPopUpFieldInfos)
        {
            priorityFieldNames.push(priorityPopUpFieldInfo.fieldName);
        }

        for each (var sourcePopUpFieldInfo:PopUpFieldInfo in secondaryPopUpFieldInfos)
        {
            if (priorityFieldNames.indexOf(sourcePopUpFieldInfo.fieldName) == -1)
            {
                mergedPopUpFieldInfos.push(sourcePopUpFieldInfo);
            }
        }

        return mergedPopUpFieldInfos;
    }

    public function importFields(fields:Array):void
    {
        fieldInfos.source = PopUpInfoUtil.popUpFieldInfosFromFields(fields);
    }
}
}
