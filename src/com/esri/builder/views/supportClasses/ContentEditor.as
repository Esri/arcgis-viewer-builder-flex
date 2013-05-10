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

import com.esri.builder.components.FieldPickerBase;
import com.esri.builder.components.FieldPickerEvent;
import com.esri.builder.views.popups.ImagePropertiesPopUp;
import com.esri.builder.views.popups.LinkPropertiesPopUp;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.IList;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.utils.StringUtil;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.SkinnableTextBase;
import spark.events.PopUpEvent;

public class ContentEditor extends SkinnableComponent
{
    [SkinPart(required="true")]
    public var contentInput:SkinnableTextBase;
    [SkinPart(required="false")]
    public var fieldPicker:FieldPickerBase;
    [SkinPart(required="true")]
    public var boldButton:ButtonBase;
    [SkinPart(required="true")]
    public var italicButton:ButtonBase;
    [SkinPart(required="true")]
    public var underlineButton:ButtonBase;
    [SkinPart(required="true")]
    public var linkButton:ButtonBase;
    [SkinPart(required="true")]
    public var imageButton:ButtonBase;

    private var _content:String;

    [Bindable(event="contentChanged")]
    public function get content():String
    {
        return _content;
    }

    public function set content(value:String):void
    {
        _content = value;
        invalidateProperties();
    }

    override protected function commitProperties():void
    {
        super.commitProperties();
        contentInput.text = content;
    }

    [Bindable]
    public var popUpFieldInfos:IList;

    private var linkPropertiesPopUp:LinkPropertiesPopUp;
    private var imagePropertiesPopUp:ImagePropertiesPopUp;

    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == contentInput)
        {
            contentInput.addEventListener(FlexEvent.VALUE_COMMIT, contentInput_valueCommitHandler);
        }
        else if (instance == fieldPicker)
        {
            fieldPicker.addEventListener(FieldPickerEvent.FIELD_SELECTED, fieldPicker_fieldSelectedHandler);
        }
        else if (instance == boldButton)
        {
            boldButton.addEventListener(MouseEvent.CLICK, boldButton_clickHandler);
        }
        else if (instance == italicButton)
        {
            italicButton.addEventListener(MouseEvent.CLICK, italicButton_clickHandler);
        }
        else if (instance == underlineButton)
        {
            underlineButton.addEventListener(MouseEvent.CLICK, underlineButton_clickHandler);
        }
        else if (instance == linkButton)
        {
            linkButton.addEventListener(MouseEvent.CLICK, linkButton_clickHandler);
        }
        else if (instance == imageButton)
        {
            imageButton.addEventListener(MouseEvent.CLICK, imageButton_clickHandler);
        }

        super.partAdded(partName, instance);
    }

    private function contentInput_valueCommitHandler(event:FlexEvent):void
    {
        _content = contentInput.text;
        dispatchEvent(new Event('contentChanged'));
    }

    private function fieldPicker_fieldSelectedHandler(event:FieldPickerEvent):void
    {
        insertIntoContent(event.template);
    }

    private function insertIntoContent(text:String):void
    {
        FieldPickerSelectionUtil.insertIntoTextSelectionAndFocus(text, contentInput);
        //updating text manually since binding does not kick in
        _content = contentInput.text
        dispatchEvent(new Event('contentChanged'));
    }

    private function boldButton_clickHandler(event:MouseEvent):void
    {
        addBoldTags();
    }

    private function addBoldTags():void
    {
        substituteWithSelectionAndInsertIntoContent("<b>{0}</b>");
    }

    private function substituteWithSelectionAndInsertIntoContent(tagTemplate:String):void
    {
        var textToWrap:String = getSelectedContentText();
        var substitutedText:String = StringUtil.substitute(tagTemplate, textToWrap);
        insertIntoContent(substitutedText);
    }

    private function getSelectedContentText():String
    {
        return FieldPickerSelectionUtil.getSelectedText(contentInput);
    }

    private function italicButton_clickHandler(event:MouseEvent):void
    {
        addItalicTags();
    }

    private function addItalicTags():void
    {
        substituteWithSelectionAndInsertIntoContent("<i>{0}</i>");
    }

    private function underlineButton_clickHandler(event:MouseEvent):void
    {
        addUnderlineTags();
    }

    private function addUnderlineTags():void
    {
        substituteWithSelectionAndInsertIntoContent("<u>{0}</u>");
    }

    private function linkButton_clickHandler(event:MouseEvent):void
    {
        addLinkTags();
    }

    private function addLinkTags():void
    {
        linkPropertiesPopUp = new LinkPropertiesPopUp();
        linkPropertiesPopUp.addEventListener(PopUpEvent.CLOSE, linkTextPopUp_closeHandler);
        linkPropertiesPopUp.overrideDescription(getSelectedContentText());
        linkPropertiesPopUp.popUpFieldInfos = popUpFieldInfos;
        linkPropertiesPopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    protected function linkTextPopUp_closeHandler(event:PopUpEvent):void
    {
        linkPropertiesPopUp.removeEventListener(PopUpEvent.CLOSE, linkTextPopUp_closeHandler);
        linkPropertiesPopUp = null;
        if (event.commit)
        {
            const linkProperties:LinkProperties = event.data;
            if (linkProperties.description)
            {
                const urlAndDescriptionTemplate:String = '<a href="{0}">{1}</a>';
                insertIntoContent(StringUtil.substitute(urlAndDescriptionTemplate,
                                                        linkProperties.url,
                                                        linkProperties.description));
            }
            else
            {
                const urlOnlyTemplate:String = '<a href="{0}">{0}</a>';
                insertIntoContent(StringUtil.substitute(urlOnlyTemplate,
                                                        linkProperties.url));
            }
        }
    }

    private function imageButton_clickHandler(event:MouseEvent):void
    {
        addImageTags();
    }

    private function addImageTags():void
    {
        imagePropertiesPopUp = new ImagePropertiesPopUp();
        imagePropertiesPopUp.addEventListener(PopUpEvent.CLOSE, imagePropertiesPopUp_closeHandler);
        imagePropertiesPopUp.popUpFieldInfos = popUpFieldInfos;
        imagePropertiesPopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    protected function imagePropertiesPopUp_closeHandler(event:PopUpEvent):void
    {
        imagePropertiesPopUp.removeEventListener(PopUpEvent.CLOSE, imagePropertiesPopUp_closeHandler);
        imagePropertiesPopUp = null;
        if (event.commit)
        {
            insertIntoContent('<img src="' + event.data + '"/>');
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == contentInput)
        {
            contentInput.removeEventListener(FlexEvent.VALUE_COMMIT, contentInput_valueCommitHandler);
        }
        else if (instance == fieldPicker)
        {
            fieldPicker.removeEventListener(FieldPickerEvent.FIELD_SELECTED, fieldPicker_fieldSelectedHandler);
        }
        else if (instance == boldButton)
        {
            boldButton.removeEventListener(MouseEvent.CLICK, boldButton_clickHandler);
        }
        else if (instance == italicButton)
        {
            italicButton.removeEventListener(MouseEvent.CLICK, italicButton_clickHandler);
        }
        else if (instance == underlineButton)
        {
            underlineButton.removeEventListener(MouseEvent.CLICK, underlineButton_clickHandler);
        }
        else if (instance == linkButton)
        {
            linkButton.removeEventListener(MouseEvent.CLICK, linkButton_clickHandler);
        }
        else if (instance == imageButton)
        {
            imageButton.removeEventListener(MouseEvent.CLICK, imageButton_clickHandler);
        }

        super.partRemoved(partName, instance);
    }
}
}
