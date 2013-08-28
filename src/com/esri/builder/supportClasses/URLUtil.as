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

    public static function removeToken(url:String):String
    {
        const tokenKeyValue:RegExp = / &? token = [a-zA-Z0-9]* /igx;
        var cleanURL:String = url ? url.replace(tokenKeyValue, "") : "";

        const invalidQueryStringCharSequence:RegExp = / (\?) & /x;
        cleanURL = cleanURL.replace(invalidQueryStringCharSequence, "$1");

        const endingQueryDelimiter:RegExp = / \? \s* $ /x;
        return cleanURL.replace(endingQueryDelimiter, "");
    }

    public static function extractToken(url:String):String
    {
        var token:String = "";

        if (url)
        {
            const tokenKeyValue:RegExp = / &? token = ([a-zA-Z0-9]*) /ix;
            var matches:Array = tokenKeyValue.exec(url);
            if (matches && matches.length > 1) //want the first captured group (the token value)
            {
                token = matches[1];
            }
        }

        return token;
    }

    public static function ensureValidKeyValuePairs(url:String):String
    {
        if (url == null)
        {
            url = "";
        }

        var queryDelimiterIndex:int = url.indexOf("?");
        if (queryDelimiterIndex == -1)
        {
            return url;
        }

        var queryString:String = url.substr(queryDelimiterIndex + 1);
        url = url.substr(0, queryDelimiterIndex);

        var key:String;
        var value:String;
        var validKVPairs:Array = [];
        var kvPairs:Array = queryString.split("&");
        var kvPair:Array;

        for each (var kv:String in kvPairs)
        {
            kvPair = kv.split("=");

            if (kvPair.length < 2)
            {
                continue;
            }

            key = kvPair[0];
            value = kvPair[1];

            if (key && value)
            {
                validKVPairs.push(key + "=" + value);
            }
        }

        queryString = validKVPairs.length > 0 ?
            "?" + validKVPairs.join("&") : "";

        return url + queryString;
    }

    public static function removeQueryString(url:String):String
    {
        if (url == null)
        {
            url = "";
        }

        var queryDelimiterIndex:int = url.indexOf("?");
        return (queryDelimiterIndex > -1) ? url.substr(0, queryDelimiterIndex) : url;
    }

    public static function extractQueryString(url:String):String
    {
        if (url == null)
        {
            url = "";
        }

        var queryDelimiterIndex:int = url.indexOf("?");
        return (queryDelimiterIndex > -1) ? url.substr(queryDelimiterIndex) : "";
    }
}
}
