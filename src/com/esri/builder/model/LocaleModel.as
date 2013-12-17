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

import mx.core.LayoutDirection;
import mx.resources.ResourceManager;

public class LocaleModel
{
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

    private var _locales:Array;

    public function get locales():Array
    {
        return _locales;
    }

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
        initLocales();
    }

    private function initLocales():void
    {
        const appLocales:Array = ResourceManager.getInstance().localeChain;
        var isLocaleSupported:Boolean;
        _locales = [];

        for each (var locale:Locale in WellKnownLocales.locales)
        {
            isLocaleSupported = appLocales.indexOf(locale.id) > -1;
            if (isLocaleSupported)
            {
                _locales.push(locale);
            }
        }
    }

    public function getLocaleLayoutDirection(localeId:String):String
    {
        return (localeId == WellKnownLocales.ARABIC_ID
            || localeId == WellKnownLocales.HEBREW_ID) ?
            LayoutDirection.RTL : LayoutDirection.LTR;
    }
}
}

import com.esri.builder.model.Locale;

class WellKnownLocales
{
    public static const ARABIC_ID:String = 'ar';
    public static const DANISH_ID:String = 'da_DK';
    public static const GERMAN_ID:String = 'de_DE';
    public static const ENGLISH_ID:String = 'en_US';
    public static const ESTONIAN_ID:String = 'et_EE';
    public static const SPANISH_ID:String = 'es_ES';
    public static const FINNISH_ID:String = 'fi_FI';
    public static const FRENCH_ID:String = 'fr_FR';
    public static const HEBREW_ID:String = 'he_IL';
    public static const ITALIAN_ID:String = 'it_IT';
    public static const JAPANESE_ID:String = 'ja_JP';
    public static const KOREAN_ID:String = 'ko_KR';
    public static const LATVIAN_ID:String = 'lv_LV';
    public static const LITHUANIAN_ID:String = 'lt_LT';
    public static const NORWEGIAN_ID:String = 'nb_NO';
    public static const DUTCH_ID:String = 'nl_NL';
    public static const POLISH_ID:String = 'pl_PL';
    public static const PORTUGUESE_BRAZIL_ID:String = 'pt_BR';
    public static const PORTUGUESE_PORTUGAL_ID:String = 'pt_PT';
    public static const ROMANIAN_ID:String = 'ro_RO';
    public static const RUSSIAN_ID:String = 'ru_RU';
    public static const SWEDISH_ID:String = 'sv_SE';
    public static const CHINESE_SIMPLIFIED_HAN_ID:String = 'zh_CN';

    private static const ARABIC_LABEL:String = "Arabic-عربي";
    private static const DANISH_LABEL:String = "Danish-Dansk";
    private static const GERMAN_LABEL:String = "German-Deutsch";
    private static const ESTONIAN_LABEL:String = "Estonian-Eesti";
    private static const ENGLISH_LABEL:String = "English-English";
    private static const SPANISH_LABEL:String = "Spanish-Español";
    private static const FINNISH_LABEL:String = "Finnish-Suomi";
    private static const FRENCH_LABEL:String = "French-Français";
    private static const HEBREW_LABEL:String = "Hebrew-עברית";
    private static const ITALIAN_LABEL:String = "Italian-Italiano";
    private static const JAPANESE_LABEL:String = "Japanese-日本語";
    private static const KOREAN_LABEL:String = "Korean-한국어";
    private static const LATVIAN_LABEL:String = "Latvian-Latviešu";
    private static const LITHUANIAN_LABEL:String = "Lithuanian-Lietuvių";
    private static const NORWEGIAN_LABEL:String = "Norwegian-Norsk";
    private static const DUTCH_LABEL:String = "Dutch-Nederlands";
    private static const POLISH_LABEL:String = "Polish-Polski";
    private static const PORTUGUESE_BRAZIL_LABEL:String = "Portuguese (Brazil)-Português (Brasil)";
    private static const PORTUGUESE_PORTUGAL_LABEL:String = "Portuguese (Portugal)-Português (Portugal)";
    private static const ROMANIAN_LABEL:String = "Romanian-Română";
    private static const RUSSIAN_LABEL:String = "Russian-Русский";
    private static const SWEDISH_LABEL:String = "Swedish-Svenska";
    private static const CHINESE_SIMPLIFIED_HAN_LABEL:String = "Chinese (Simplified Han)-简体中文";

    public static const locales:Array = [
        new Locale(ARABIC_ID, ARABIC_LABEL),
        new Locale(CHINESE_SIMPLIFIED_HAN_ID, CHINESE_SIMPLIFIED_HAN_LABEL),
        new Locale(DANISH_ID, DANISH_LABEL),
        new Locale(DUTCH_ID, DUTCH_LABEL),
        new Locale(ENGLISH_ID, ENGLISH_LABEL),
        new Locale(ESTONIAN_ID, ESTONIAN_LABEL),
        new Locale(FINNISH_ID, FINNISH_LABEL),
        new Locale(FRENCH_ID, FRENCH_LABEL),
        new Locale(GERMAN_ID, GERMAN_LABEL),
        new Locale(HEBREW_ID, HEBREW_LABEL),
        new Locale(ITALIAN_ID, ITALIAN_LABEL),
        new Locale(JAPANESE_ID, JAPANESE_LABEL),
        new Locale(KOREAN_ID, KOREAN_LABEL),
        new Locale(LATVIAN_ID, LATVIAN_LABEL),
        new Locale(LITHUANIAN_ID, LITHUANIAN_LABEL),
        new Locale(NORWEGIAN_ID, NORWEGIAN_LABEL),
        new Locale(POLISH_ID, POLISH_LABEL),
        new Locale(PORTUGUESE_BRAZIL_ID, PORTUGUESE_BRAZIL_LABEL),
        new Locale(PORTUGUESE_PORTUGAL_ID, PORTUGUESE_PORTUGAL_LABEL),
        new Locale(ROMANIAN_ID, ROMANIAN_LABEL),
        new Locale(RUSSIAN_ID, RUSSIAN_LABEL),
        new Locale(SPANISH_ID, SPANISH_LABEL),
        new Locale(SWEDISH_ID, SWEDISH_LABEL)
        ];
}

class SingletonEnforcer
{
}
