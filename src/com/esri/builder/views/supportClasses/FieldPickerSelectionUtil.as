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

import mx.core.UIComponent;

import spark.components.supportClasses.SkinnableTextBase;

public class FieldPickerSelectionUtil
{
    public static function insertIntoTextSelectionAndFocus(text:String, textInputComponent:SkinnableTextBase):void
    {
        setSelectionIfNeeded(textInputComponent);
        textInputComponent.insertText(text);
        textInputComponent.callLater(focusComponent, [ textInputComponent ]); //calling later to prevent issue where template field pop-up stays open
    }

    private static function setSelectionIfNeeded(textInput:SkinnableTextBase):void
    {
        var selectionAnchorPosition:int = textInput.selectionAnchorPosition;
        var selectionActivePosition:int = textInput.selectionActivePosition;
        var hasInvalidRange:Boolean = (selectionAnchorPosition == -1 && selectionActivePosition == -1);
        if (hasInvalidRange)
        {
            textInput.selectRange(0, 0);
        }
    }

    private static function focusComponent(component:UIComponent):void
    {
        component.setFocus();
    }

    public static function getSelectedText(textInputComponent:SkinnableTextBase):String
    {
        var selectionAnchorPosition:int = textInputComponent.selectionAnchorPosition;
        var selectionActivePosition:int = textInputComponent.selectionActivePosition;
        return textInputComponent.text.substring(selectionAnchorPosition,
                                                 selectionActivePosition);
    }
}
}
