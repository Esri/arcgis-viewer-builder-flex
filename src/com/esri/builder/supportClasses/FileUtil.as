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

import flash.filesystem.File;

import mx.utils.StringUtil;

public class FileUtil
{
    public static function generateUniqueRelativePath(baseDirectory:File, relativeFilePath:String, relativePathBlackList:Array = null):String
    {
        var currentID:int = 1;
        var extensionIndex:int = relativeFilePath.lastIndexOf(".");
        var extension:String = "";
        if (extensionIndex > -1)
        {
            extension = relativeFilePath.substr(extensionIndex);
            relativeFilePath = relativeFilePath.substr(0, extensionIndex);
        }
        var filenameTemplate:String = relativeFilePath + "_{0}" + extension;
        var uniqueWidgetConfigPath:String;

        do
        {
            uniqueWidgetConfigPath = StringUtil.substitute(filenameTemplate, currentID++);
        } while (doesFileExist(baseDirectory, uniqueWidgetConfigPath, relativePathBlackList));

        return uniqueWidgetConfigPath;
    }

    private static function doesFileExist(baseDirectory:File, relativeFilePath:String, relativePathBlackList:Array):Boolean
    {
        if (relativePathBlackList
            && relativePathBlackList.indexOf(relativeFilePath) > -1)
        {
            return true;
        }

        var fileToCheck:File = baseDirectory.resolvePath(relativeFilePath);
        return fileToCheck.exists;
    }

    public static function getFileName(file:File):String
    {
        return file.name.replace("." + file.extension, "");
    }
}
}
