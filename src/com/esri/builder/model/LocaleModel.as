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

import flash.utils.Dictionary;

import mx.core.LayoutDirection;
import mx.resources.ResourceManager;

public class LocaleModel
{
    private static const ARABIC_LOCALE_ID:String = 'ar';
    private static const DANISH_LOCALE_ID:String = 'da_DK';
    private static const GERMAN_LOCALE_ID:String = 'de_DE';
    private static const ENGLISH_LOCALE_ID:String = 'en_US';
    private static const ESTONIAN_LOCALE_ID:String = 'et_EE';
    private static const SPANISH_LOCALE_ID:String = 'es_ES';
    private static const FINNISH_LOCALE_ID:String = 'fi_FI';
    private static const FRENCH_LOCALE_ID:String = 'fr_FR';
    private static const HEBREW_LOCALE_ID:String = 'he_IL';
    private static const ITALIAN_LOCALE_ID:String = 'it_IT';
    private static const JAPANESE_LOCALE_ID:String = 'ja_JP';
    private static const KOREAN_LOCALE_ID:String = 'ko_KR';
    private static const LATVIAN_LOCALE_ID:String = 'lv_LV';
    private static const LITHUANIAN_LOCALE_ID:String = 'lt_LT';
    private static const NORWEGIAN_LOCALE_ID:String = 'nb_NO';
    private static const DUTCH_LOCALE_ID:String = 'nl_NL';
    private static const POLISH_LOCALE_ID:String = 'pl_PL';
    private static const PORTUGUESE_BRAZIL_LOCALE_ID:String = 'pt_BR';
    private static const PORTUGUESE_PORTUGAL_LOCALE_ID:String = 'pt_PT';
    private static const ROMANIAN_LOCALE_ID:String = 'ro_RO';
    private static const RUSSIAN_LOCALE_ID:String = 'ru_RU';
    private static const SWEDISH_LOCALE_ID:String = 'sv_SE';
    private static const CHINESE_SIMPLIFIED_HAN_LOCALE_ID:String = 'zh_CN';

    public static const PREFERRED_ARABIC_FONTS:Array = [ 'Tahoma' ];

    public static const PREFERRED_JAPANESE_FONTS:Array = [ 'メイリオ',
                                                           'ＭＳ Ｐゴシック',
                                                           'ＭＳ Ｐ明朝',
                                                           'ＭＳ 明朝',
                                                           'MS UI Gothic',
                                                           'ＭＳ ゴシック' ];

    public static const PREFERRED_KOREAN_FONTS:Array = [ 'Malgun Gothic',
                                                         'Batang' ];

    public static const PREFERRED_CHINESE_FONTS:Array = [ 'SimSun',
                                                          'FangSong',
                                                          'SIMHEI' ];

    private static var instance:LocaleModel;

    private var localeIdToLabel:Dictionary;
    private var localeIdToLocaleOption:Dictionary;

    public static function getInstance():LocaleModel
    {
        if (!instance)
        {
            instance = new LocaleModel(new SingletonEnforcer());
        }

        return instance;
    }

    public function LocaleModel(singletonEnforcer:SingletonEnforcer)
    {
        initLocaleLabels();
        initLocaleOptions();
    }

    private function initLocaleLabels():void
    {
        localeIdToLabel = new Dictionary();

        localeIdToLabel[ARABIC_LOCALE_ID] = "Arabic-عربي";
        localeIdToLabel[DANISH_LOCALE_ID] = "Danish-Dansk";
        localeIdToLabel[GERMAN_LOCALE_ID] = "German-Deutsch";
        localeIdToLabel[ESTONIAN_LOCALE_ID] = "Estonian-Eesti";
        localeIdToLabel[ENGLISH_LOCALE_ID] = "English-English";
        localeIdToLabel[SPANISH_LOCALE_ID] = "Spanish-Español";
        localeIdToLabel[FINNISH_LOCALE_ID] = "Finnish-Suomi";
        localeIdToLabel[FRENCH_LOCALE_ID] = "French-Français";
        localeIdToLabel[HEBREW_LOCALE_ID] = "Hebrew-עברית";
        localeIdToLabel[ITALIAN_LOCALE_ID] = "Italian-Italiano";
        localeIdToLabel[JAPANESE_LOCALE_ID] = "Japanese-日本語";
        localeIdToLabel[KOREAN_LOCALE_ID] = "Korean-한국어";
        localeIdToLabel[LATVIAN_LOCALE_ID] = "Latvian-Latviešu";
        localeIdToLabel[LITHUANIAN_LOCALE_ID] = "Lithuanian-Lietuvių";
        localeIdToLabel[NORWEGIAN_LOCALE_ID] = "Norwegian-Norsk";
        localeIdToLabel[DUTCH_LOCALE_ID] = "Dutch-Nederlands";
        localeIdToLabel[POLISH_LOCALE_ID] = "Polish-Polski";
        localeIdToLabel[PORTUGUESE_BRAZIL_LOCALE_ID] = "Portuguese (Brazil)-Português (Brasil)";
        localeIdToLabel[PORTUGUESE_PORTUGAL_LOCALE_ID] = "Portuguese (Portugal)-Português (Portugal)";
        localeIdToLabel[ROMANIAN_LOCALE_ID] = "Romanian-Română";
        localeIdToLabel[RUSSIAN_LOCALE_ID] = "Russian-Русский";
        localeIdToLabel[SWEDISH_LOCALE_ID] = "Swedish-Svenska";
        localeIdToLabel[CHINESE_SIMPLIFIED_HAN_LOCALE_ID] = "Chinese (Simplified Han)-简体中文";
    }

    private function initLocaleOptions():void
    {
        var localeChain:Array = ResourceManager.getInstance().localeChain;
        localeIdToLocaleOption = new Dictionary();
        for each (var localeId:String in localeChain)
        {
            localeIdToLocaleOption[localeId] = new LocaleOption(localeId);
        }
    }

    public function getLabel(localeId:String):String
    {
        var localeLabel:String = localeIdToLabel[localeId];
        return localeLabel ? localeLabel : "";
    }

    public function getAvailableLocaleOptions():Array
    {
        var availableLocaleOptions:Array = [];

        for each (var localeId:String in supportedLocaleIds)
        {
            if (localeIdToLocaleOption[localeId])
            {
                availableLocaleOptions.push(localeIdToLocaleOption[localeId]);
            }
        }

        return availableLocaleOptions;
    }

    private const supportedLocaleIds:Array = [
        ARABIC_LOCALE_ID,
        CHINESE_SIMPLIFIED_HAN_LOCALE_ID,
        DANISH_LOCALE_ID,
        DUTCH_LOCALE_ID,
        ENGLISH_LOCALE_ID,
        ESTONIAN_LOCALE_ID,
        FINNISH_LOCALE_ID,
        FRENCH_LOCALE_ID,
        GERMAN_LOCALE_ID,
        HEBREW_LOCALE_ID,
        ITALIAN_LOCALE_ID,
        JAPANESE_LOCALE_ID,
        KOREAN_LOCALE_ID,
        LATVIAN_LOCALE_ID,
        LITHUANIAN_LOCALE_ID,
        NORWEGIAN_LOCALE_ID,
        POLISH_LOCALE_ID,
        PORTUGUESE_BRAZIL_LOCALE_ID,
        PORTUGUESE_PORTUGAL_LOCALE_ID,
        ROMANIAN_LOCALE_ID,
        RUSSIAN_LOCALE_ID,
        SPANISH_LOCALE_ID,
        SWEDISH_LOCALE_ID
        ];

    public function getLocaleLayoutDirection(localeId:String):String
    {
        return (localeId == ARABIC_LOCALE_ID || localeId == HEBREW_LOCALE_ID) ?
            LayoutDirection.RTL : LayoutDirection.LTR;
    }
}
}

class SingletonEnforcer
{
}
