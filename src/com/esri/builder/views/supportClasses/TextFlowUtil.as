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

import com.esri.builder.supportClasses.URLUtil;

import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.elements.Configuration;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.formats.TextDecoration;
import flashx.textLayout.formats.TextLayoutFormat;

import mx.utils.StringUtil;

public class TextFlowUtil
{
    public static function toURLFlow(url:String, label:String = null):TextFlow
    {
        if (!label)
        {
            label = url;
        }

        var urlSource:String =
            StringUtil.substitute("<a href='{0}'>{1}</a>", URLUtil.decode(url), label);

        return TextConverter.importToFlow(urlSource,
                                          TextConverter.TEXT_FIELD_HTML_FORMAT,
                                          getURLConfig());
    }

    private static function getURLConfig():IConfiguration
    {
        var config:Configuration = TextFlow.defaultConfiguration;

        var activeFormat:TextLayoutFormat = new TextLayoutFormat(config.defaultLinkActiveFormat);
        activeFormat.color = 0x000000;
        activeFormat.textDecoration = TextDecoration.UNDERLINE;

        var hoverFormat:TextLayoutFormat = new TextLayoutFormat(config.defaultLinkHoverFormat);
        hoverFormat.color = 0x000000;
        hoverFormat.textDecoration = TextDecoration.UNDERLINE;

        var normalFormat:TextLayoutFormat = new TextLayoutFormat(config.defaultLinkNormalFormat);
        normalFormat.color = 0x007AC2;
        normalFormat.textDecoration = TextDecoration.UNDERLINE;

        config.defaultLinkActiveFormat = activeFormat;
        config.defaultLinkHoverFormat = hoverFormat;
        config.defaultLinkNormalFormat = normalFormat;

        return config;
    }
}
}
