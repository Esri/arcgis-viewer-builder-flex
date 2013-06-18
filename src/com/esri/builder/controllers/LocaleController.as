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

import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.LocaleModel;
import com.esri.builder.model.Model;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.supportClasses.LogUtil;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IStyleManager2;
import mx.styles.StyleManager;

public class LocaleController
{
    private static const LOG:ILogger = LogUtil.createLogger(LocaleController);

    public function LocaleController()
    {
        AppEvent.addListener(AppEvent.SETTINGS_SAVED, settingsChangeHandler, false, 500); //high priority to prevent app using outdated locale settings
    }

    private function settingsChangeHandler(event:AppEvent):void
    {
        updateApplicationLocale();
    }

    private function updateApplicationLocale():void
    {
        var selectedLocale:String = Model.instance.locale;
        var localeChain:Array = ResourceManager.getInstance().localeChain;

        var selectedLocaleIndex:int = localeChain.indexOf(selectedLocale);
        localeChain.splice(selectedLocaleIndex, 1);
        localeChain.unshift(selectedLocale);

        if (Log.isDebug())
        {
            LOG.debug("Updating application locale: {0}", selectedLocale);
        }

        ResourceManager.getInstance().update();
        applyLocaleLayoutDirection(selectedLocale);
        setPreferredLocaleFonts(selectedLocale);
        setLocaleSpecificStyles(selectedLocale);
    }

    private function applyLocaleLayoutDirection(selectedLocale:String):void
    {
        var currentLayoutDirection:String = FlexGlobals.topLevelApplication.getStyle('layoutDirection');
        var localeLayoutDirection:String = LocaleModel.getInstance().getLocaleLayoutDirection(selectedLocale);
        if (localeLayoutDirection != currentLayoutDirection)
        {
            FlexGlobals.topLevelApplication.setStyle('direction', localeLayoutDirection);
            FlexGlobals.topLevelApplication.setStyle('layoutDirection', localeLayoutDirection);
        }

        var currentLocale:String = FlexGlobals.topLevelApplication.getStyle('locale');
        if (selectedLocale != currentLocale)
        {
            FlexGlobals.topLevelApplication.setStyle('locale', selectedLocale);
            WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.sort();
        }
    }

    private function setPreferredLocaleFonts(selectedLocale:String):void
    {
        if (selectedLocale == 'ar')
        {
            FlexGlobals.topLevelApplication.setStyle('fontFamily', LocaleModel.ARABIC_FONT_FAMILY);
        }
        else if (selectedLocale == 'ja_JP')
        {
            FlexGlobals.topLevelApplication.setStyle('fontFamily', LocaleModel.JAPANESE_FONT_FAMILY);
        }
        else if (selectedLocale == 'ko_KR')
        {
            FlexGlobals.topLevelApplication.setStyle('fontFamily', LocaleModel.KOREAN_FONT_FAMILY);
        }
        else if (selectedLocale == 'zh_CN')
        {
            FlexGlobals.topLevelApplication.setStyle('fontFamily', LocaleModel.CHINESE_FONT_FAMILY);
        }
        else
        {
            FlexGlobals.topLevelApplication.setStyle('fontFamily', undefined);
        }
    }

    private function setLocaleSpecificStyles(locale:String):void
    {
        var topLevelStyleManager:IStyleManager2 = StyleManager.getStyleManager(null);

        var isItalicInappropriateLocale:Boolean =
            locale == 'ja_JP' || locale == 'ko_KR' || locale == 'zh_CN'
            || locale == 'ar' || locale == 'he_IL';

        var emphasisStyle:CSSStyleDeclaration = topLevelStyleManager.getStyleDeclaration(".emphasisText");
        var emphasisFontStyle:String = isItalicInappropriateLocale ? "normal" : "italic";
        emphasisStyle.setStyle("fontStyle", emphasisFontStyle);

        var isBoldInappropriateLocale:Boolean =
            locale == 'ja_JP' || locale == 'ko_KR' || locale == 'zh_CN';

        var boldStyle:CSSStyleDeclaration = topLevelStyleManager.getStyleDeclaration(".boldText");
        var emphasisFontWeight:String = isBoldInappropriateLocale ? "normal" : "bold";
        boldStyle.setStyle("fontWeight", emphasisFontWeight);
    }
}
}
