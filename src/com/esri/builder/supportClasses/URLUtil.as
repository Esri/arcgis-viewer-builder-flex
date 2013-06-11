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

public class URLUtil
{
    public static function encode(url:String):String
    {
        return encodeURI(decode(url));
    }

    public static function decode(url:String):String
    {
        return decodeURI(encodePercentChars(url));
    }

    private static function encodePercentChars(url:String):String
    {
        const nonEncodedPercentCharacters:RegExp = / % (?! [0-9a-fA-F]{2} ) /gx;
        return url ? url.replace(nonEncodedPercentCharacters, "%25") : "";
    }

    public static function ensureTrailingForwardSlash(url:String):String
    {
        if (isValidURL(url))
        {
            return url.charAt(url.length - 1) == "/" ? url : url + "/";
        }
        else
        {
            return url;
        }
    }

    public static function isValidURL(url:String):Boolean
    {
        const SIMPLE_URL_EXPR:RegExp = /^ (?: f|ht)tps? :\/\/ .+ $/ix;
        return SIMPLE_URL_EXPR.test(url);
    }
}
}
