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
package com.esri.builder.components
{

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.core.mx_internal;
import mx.logging.targets.LineFormattedTarget;

use namespace mx_internal;

public class LogFileTarget extends LineFormattedTarget
{
    private static const MAX_SIZE_IN_BYTES:Number = 1000000;
    public static const LOG_FILE_NAME:String = "ab-log.txt";

    private var outputFile:File;
    private var fileStream:FileStream;

    public function LogFileTarget()
    {
        createLogFile();
        fileStream = new FileStream();
    }

    private function createLogFile():void
    {
        outputFile = File.applicationStorageDirectory.resolvePath(LOG_FILE_NAME);
    }

    override mx_internal function internalLog(message:String):void
    {
        try
        {
            writeToFile(message);
        }
        catch (error:Error)
        {
            trace(error.getStackTrace());
        }
    }

    private function writeToFile(message:String):void
    {
        const newTextBytes:ByteArray = new ByteArray();
        newTextBytes.writeUTFBytes(message + "\n");

        fileStream.open(outputFile, FileMode.UPDATE);
        const currentTextBytes:ByteArray = new ByteArray();
        fileStream.readBytes(currentTextBytes);

        //writing at start of file
        fileStream.position = 0;
        fileStream.writeBytes(newTextBytes, 0, newTextBytes.length);
        fileStream.writeBytes(currentTextBytes, 0, currentTextBytes.length);

        if (outputFile.size > MAX_SIZE_IN_BYTES)
        {
            fileStream.position = MAX_SIZE_IN_BYTES;
            fileStream.truncate();
        }

        fileStream.close();
    }
}
}
