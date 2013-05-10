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

import com.esri.builder.controllers.supportClasses.HTMLWrapperUpdater;
import com.esri.builder.controllers.supportClasses.XMLFileReader;

import flash.filesystem.File;

import mx.resources.ResourceManager;

public class UpdateWebPageFilesProcess extends Process
{
    private var sourceAppDirectory:File;
    private var destinationAppDirectory:File;
    private var configReader:XMLFileReader;

    public function UpdateWebPageFilesProcess(sourceAppDirectory:File, destinationAppDirectory:File, configReader:XMLFileReader)
    {
        this.sourceAppDirectory = sourceAppDirectory;
        this.destinationAppDirectory = destinationAppDirectory;
        this.configReader = configReader;
    }

    override public function execute():void
    {
        try
        {
            var destinationConfigXML:XML = readConfigXML(destinationAppDirectory);
            updateWebPageFile("index.html");
            updateWebPageFile("default.htm");
            var htmlWrapperUpdater:HTMLWrapperUpdater = new HTMLWrapperUpdater();
            htmlWrapperUpdater.updateHTMLWrapper(destinationAppDirectory, destinationConfigXML);
            dispatchSuccess("Updated HTML files");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'appUpgradeProcess.couldNotUpdateWebPageFiles',
                                                                              [ error.message ]);
            dispatchFailure(errorMessage);
        }
    }

    public function readConfigXML(appDirectory:File):XML
    {
        var configFile:File = appDirectory.resolvePath('config.xml');
        return configReader.readFile(configFile);
    }

    //TODO: similar to CopyRootFilesProcess#copyFile - refactor into own class - FileMover/Copier?
    public function updateWebPageFile(webPageFileName:String):void
    {
        var sourceWebPageFile:File = sourceAppDirectory.resolvePath(webPageFileName);
        var destinationWebPageFile:File = destinationAppDirectory.resolvePath(webPageFileName);
        sourceWebPageFile.copyTo(destinationWebPageFile, true);
    }
}
}
