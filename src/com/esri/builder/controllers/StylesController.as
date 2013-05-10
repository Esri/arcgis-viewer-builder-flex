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
package com.esri.builder.controllers
{

import com.esri.builder.controllers.supportClasses.LocalConnectionDelegate;
import com.esri.builder.eventbus.AppEvent;

public final class StylesController
{

    public var localConnectionDelegate:LocalConnectionDelegate;

    public function StylesController()
    {
        AppEvent.addListener(AppEvent.CHANGE_TEXT_COLOR, onChangeTextColor, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_BACKGROUND_COLOR, onChangeBackgroundColor, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_ROLLOVER_COLOR, onChangeRollOverColor, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_SELECTION_COLOR, onChangeSelectionColor, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_TITLE_COLOR, onChangeTitleColor, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_FONT_NAME, onChangeFontName, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_APP_TITLE_FONT_NAME, onChangeAppTitleFontName, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_SUB_TITLE_FONT_NAME, onChangeSubTitleFontName, false, 0, true);
        AppEvent.addListener(AppEvent.CHANGE_ALPHA, onChangeAlpha, false, 0, true);
        AppEvent.addListener(AppEvent.SET_PREDEFINED_STYLES, onSetPredefinedStyles, false, 0, true);

    }

    private function onChangeTextColor(event:AppEvent):void
    {
        textColor(event.data as uint);
    }

    private function onChangeBackgroundColor(event:AppEvent):void
    {
        backgroundColor(event.data as uint);
    }

    private function onChangeRollOverColor(event:AppEvent):void
    {
        rolloverColor(event.data as uint);
    }

    private function onChangeSelectionColor(event:AppEvent):void
    {
        selectionColor(event.data as uint);
    }


    private function onChangeTitleColor(event:AppEvent):void
    {
        titleColor(event.data as uint);
    }

    private function onChangeFontName(event:AppEvent):void
    {
        fontName(event.data as String);
    }


    private function onChangeAppTitleFontName(event:AppEvent):void
    {
        appTitleFontName(event.data as String);
    }

    private function onChangeSubTitleFontName(event:AppEvent):void
    {
        subTitleFontName(event.data as String);
    }

    private function onChangeAlpha(event:AppEvent):void
    {
        alpha(event.data as Number);
    }

    private function onSetPredefinedStyles(event:AppEvent):void
    {
        setPredefinedStyles(event.data);
    }

    private function textColor(color:uint):void
    {
        localConnectionDelegate.setTextColor(color);
    }

    private function backgroundColor(color:uint):void
    {
        localConnectionDelegate.setBackgroundColor(color);
    }

    private function rolloverColor(color:uint):void
    {
        localConnectionDelegate.setRolloverColor(color);
    }

    private function selectionColor(color:uint):void
    {
        localConnectionDelegate.setSelectionColor(color);
    }

    private function titleColor(color:uint):void
    {
        localConnectionDelegate.setTitleColor(color);
    }

    private function fontName(value:String):void
    {
        localConnectionDelegate.setFontName(value);
    }

    private function appTitleFontName(value:String):void
    {
        localConnectionDelegate.setAppTitleFontName(value);
    }

    private function subTitleFontName(value:String):void
    {
        localConnectionDelegate.setSubTitleFontName(value);
    }

    private function alpha(value:Number):void
    {
        localConnectionDelegate.setAlpha(value);
    }

    private function setPredefinedStyles(value:Object):void
    {
        localConnectionDelegate.setPredefinedStyles(value);
    }
}
}
