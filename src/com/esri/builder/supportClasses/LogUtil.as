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

import com.esri.builder.logging.SimpleLogDecorator;

import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;

public class LogUtil
{
    public static function createLogger(classToLog:Class):ILogger
    {
        if (classToLog == null)
        {
            throw new Error("Cannot create logger for null");
        }

        var qualifiedClassName:String = getQualifiedClassName(classToLog);
        return new SimpleLogDecorator(Log.getLogger(qualifiedClassName.replace('::', '.')));
    }
}
}
