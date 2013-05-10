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
package com.esri.builder.controllers.supportClasses.processes
{

import com.esri.builder.controllers.supportClasses.*;

import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.resources.ResourceManager;

import org.as3commons.zip.Zip;
import org.as3commons.zip.ZipErrorEvent;
import org.as3commons.zip.ZipFile;

public class UnzipProcess extends ImportWidgetProcess
{
    private var fileStream:FileStream;
    private var zip:Zip;

    override public function UnzipProcess(sharedData:SharedImportWidgetData, fileStream:FileStream, zip:Zip)
    {
        super(sharedData);
        this.fileStream = fileStream;
        this.zip = zip;
    }

    override public function execute():void
    {
        try
        {
            extractToDestination();
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'importWidgetProcess.couldNotUnzipFile',
                                                                              [ error.message ]);
            dispatchFailure(errorMessage);
        }
    }

    private function extractToDestination():void
    {
        fileStream.open(sharedData.zippedWidgetFile, FileMode.READ);
        var zipFileContents:ByteArray = new ByteArray();
        fileStream.readBytes(zipFileContents);
        fileStream.close();

        zip.addEventListener(Event.COMPLETE, zip_completeHandler);
        zip.addEventListener(ZipErrorEvent.PARSE_ERROR, zip_parseErrorHandler);
        zip.loadBytes(zipFileContents);
    }

    private function zip_completeHandler(event:Event):void
    {
        zip.removeEventListener(Event.COMPLETE, zip_completeHandler);
        zip.removeEventListener(ZipErrorEvent.PARSE_ERROR, zip_parseErrorHandler);
        try
        {
            processZipFiles();
            dispatchSuccess("Unzipped successfully");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'importWidgetProcess.couldNotUnzipFile',
                                                                              [ error.message ]);
            dispatchFailure(errorMessage);
        }
    }

    private function processZipFiles():void
    {
        var totalFiles:int = zip.getFileCount();
        for (var i:int = 0; i < totalFiles; i++)
        {
            processZipFile(zip.getFileAt(i));
        }
    }

    private function processZipFile(zipFile:ZipFile):void
    {
        if (zipFile.sizeUncompressed == 0 || isMacOSXFolderPath(zipFile.filename))
        {
            return;
        }

        var uncompressedFile:File = sharedData.unzipWidgetWorkspace.resolvePath(zipFile.filename);
        writeFileOut(uncompressedFile, zipFile);
    }

    private function isMacOSXFolderPath(filename:String):Boolean
    {
        return filename.toUpperCase().indexOf('__MACOSX') > -1;
    }

    private function writeFileOut(outputFile:File, zipFile:ZipFile):void
    {
        var uncompressedData:ByteArray = zipFile.content;
        fileStream.open(outputFile, FileMode.WRITE);
        fileStream.writeBytes(uncompressedData);
        fileStream.close();
    }

    private function zip_parseErrorHandler(event:ZipErrorEvent):void
    {
        zip.removeEventListener(Event.COMPLETE, zip_completeHandler);
        zip.removeEventListener(ZipErrorEvent.PARSE_ERROR, zip_parseErrorHandler);
        var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                          'importWidgetProcess.couldNotUnzipFile',
                                                                          [ event.text ]);
        dispatchFailure(errorMessage);
    }
}
}
