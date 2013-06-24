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

public class FileUtil
{
    public static function generateUniqueRelativePath(baseDirectory:File, relativeFilePath:String, relativePathBlackList:Array = null):String
    {
        var extensionIndex:int = relativeFilePath.lastIndexOf(".");
        var extension:String = "";
        if (extensionIndex > -1)
        {
            extension = relativeFilePath.substr(extensionIndex);
            relativeFilePath = relativeFilePath.substr(0, extensionIndex);
        }
        var filenameTemplate:String = relativeFilePath + "_{0}" + extension;

        var uniqueWidgetConfigPath:String =
            LabelUtil.generateUniqueLabel(filenameTemplate,
                                          relativePathBlackList,
                                          function isNonExistentFile(uniqueFilePath:String, availableNames:Array):Boolean
                                          {
                                              if (availableNames
                                                  && availableNames.indexOf(uniqueFilePath) > -1)
                                              {
                                                  return false;
                                              }

                                              return !baseDirectory.resolvePath(uniqueFilePath).exists;
                                          });
        return uniqueWidgetConfigPath;
    }

    public static function getFileName(file:File):String
    {
        return file.name.replace("." + file.extension, "");
    }

    public static function findMatchingFiles(directory:File, pattern:RegExp):Array
    {
        var moduleFiles:Array = [];

        if (directory.isDirectory)
        {
            const files:Array = directory.getDirectoryListing();

            for each (var file:File in files)
            {
                if (file.isDirectory)
                {
                    moduleFiles = moduleFiles.concat(findMatchingFiles(file, pattern));
                }
                else if (pattern.test(file.name))
                {
                    moduleFiles.push(file);
                }
            }
        }

        return moduleFiles;
    }

    public static function findMatchingFile(directory:File, pattern:RegExp):File
    {
        var matchingFile:File;

        if (directory.isDirectory)
        {
            const files:Array = directory.getDirectoryListing();

            //sort files first to reduce unnecessary directory listing calls.
            files.sortOn("isDirectory");

            for each (var file:File in files)
            {
                if (file.isDirectory)
                {
                    matchingFile = findMatchingFile(file, pattern);
                }
                else if (pattern.test(file.name))
                {
                    matchingFile = file;
                }

                if (matchingFile)
                {
                    break;
                }
            }
        }

        return matchingFile;
    }

    public static function ensureOSLineEndings(text:String):String
    {
        return text ? text.replace(/\n/g, File.lineEnding) : "";
    }
}
}
