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

import com.esri.builder.controllers.supportClasses.XMLFileReader;
import com.esri.builder.supportClasses.FileUtil;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.resources.ResourceManager;

public class PrepareMetaFileProcess extends ImportWidgetProcess
{
    private var xmlFileReader:XMLFileReader;
    private var customWidgetParentDirectory:File;

    public function PrepareMetaFileProcess(sharedData:SharedImportWidgetData, xmlFileReader:XMLFileReader)
    {
        super(sharedData);
        this.xmlFileReader = xmlFileReader;
    }

    override public function execute():void
    {
        try
        {
            customWidgetParentDirectory = sharedData.customWidgetFile.parent;

            //TODO: refactor
            var metaFile:File = findMetaXML(customWidgetParentDirectory);
            if (metaFile)
            {
                var metaXML:XML = xmlFileReader.readFile(metaFile);
                if (metaXML)
                {
                    metaXML.name = sharedData.customWidgetName;
                    writeMetaFileContents(metaFile, metaXML);
                    sharedData.metaFile = metaFile;
                    sharedData.customWidgetVersion = metaXML.widgetversion[0];
                }
                else
                {
                    sharedData.metaFile = createDefaultMetaFile();
                }
            }
            else
            {
                sharedData.metaFile = createDefaultMetaFile();
            }

            dispatchSuccess("Processed custom widget meta file");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'importWidgetProcess.couldNotCreateMetaFile');
            dispatchFailure(errorMessage);
        }
    }

    private function findMetaXML(directory:File):File
    {
        var metaXMLFileName:RegExp = /^meta\.xml$/i;
        return findFileInDirectory(metaXMLFileName, directory);
    }

    private function findFileInDirectory(fileNameRegExp:RegExp, directory:File):File
    {
        var foundFile:File;
        var directoryContents:Array = directory.getDirectoryListing();
        for each (var fileOrFolder:File in directoryContents)
        {
            if (fileNameRegExp.test(fileOrFolder.name))
            {
                foundFile = fileOrFolder;
                break;
            }
        }

        return foundFile;
    }

    private function writeMetaFileContents(metaFile:File, metaFileContents:XML):void
    {
        var fileStream:FileStream = new FileStream();
        try
        {
            fileStream.open(metaFile, FileMode.WRITE);
            fileStream.writeUTFBytes(FileUtil.ensureOSLineEndings(metaFileContents.toXMLString()));
        }
        catch (error:Error)
        {
            //TODO: throw appropriate error
        }
        finally
        {
            fileStream.close();
        }
    }

    private function createDefaultMetaFile():File
    {
        var metaFile:File = customWidgetParentDirectory.resolvePath("meta.xml");

        var metaFileContents:XML = <configuration>
                <name>{sharedData.customWidgetName}</name>
            </configuration>;

        writeMetaFileContents(metaFile, metaFileContents);

        return metaFile;
    }
}
}
