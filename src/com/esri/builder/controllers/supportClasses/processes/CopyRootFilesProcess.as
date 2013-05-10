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

import flash.filesystem.File;

import mx.resources.ResourceManager;

public class CopyRootFilesProcess extends Process
{
    private var sourceAppDirectory:File;
    private var destinationAppDirectory:File;
    private var rootFileNames:Array;

    public function CopyRootFilesProcess(sourceAppDirectory:File, destinationAppDirectory:File, rootFileNames:Array)
    {
        this.sourceAppDirectory = sourceAppDirectory;
        this.destinationAppDirectory = destinationAppDirectory;
        this.rootFileNames = rootFileNames;
    }

    override public function execute():void
    {
        try
        {
            for each (var fileName:String in rootFileNames)
            {
                copyFile(fileName);
            }

            dispatchSuccess("Copied root files!");
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'appUpgradeProcess.couldNotCopyFile',
                                                                              [ fileName, error.message ]);
            dispatchFailure(errorMessage);
        }
    }

    public function copyFile(fileName:String):void
    {
        var sourceFile:File = sourceAppDirectory.resolvePath(fileName);
        var destinationFile:File = destinationAppDirectory.resolvePath(fileName);
        sourceFile.copyTo(destinationFile, true);
    }
}
}
