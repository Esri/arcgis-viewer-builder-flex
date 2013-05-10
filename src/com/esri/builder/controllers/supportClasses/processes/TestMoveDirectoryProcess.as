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

public class TestMoveDirectoryProcess extends Process
{
    private var sourceDirectory:File;
    private var tempDirectory:File;

    public function TestMoveDirectoryProcess(sourceDirectory:File)
    {
        this.sourceDirectory = sourceDirectory;
    }

    override public function execute():void
    {
        tempDirectory = File.applicationStorageDirectory.resolvePath("__moveTest__");

        try
        {
            sourceDirectory.moveTo(tempDirectory, true);
            tempDirectory.moveTo(sourceDirectory, true);
            dispatchSuccess("Directory is movable");
        }
        catch (error:Error)
        {
            restoreContents();
            attemptDirectoryDeletion(tempDirectory);

            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                              'appUpgradeProcess.couldNotMoveDirectory',
                                                                              [ sourceDirectory.nativePath ]);
            dispatchFailure(errorMessage);
        }
    }

    private function attemptDirectoryDeletion(directory:File):void
    {
        try
        {
            directory.deleteDirectory(true);
        }
        catch (error:Error)
        {
            //handle silently
        }
    }

    private function restoreContents():void
    {
        if (!tempDirectory.exists)
        {
            return;
        }

        var tempFileStorageListing:Array = tempDirectory.getDirectoryListing();
        for each (var file:File in tempFileStorageListing)
        {
            attemptFileMove(file, sourceDirectory.resolvePath(file.name));
        }
    }

    private function attemptFileMove(sourceFile:File, destinationFile:File):void
    {
        try
        {
            sourceFile.moveTo(destinationFile);
        }
        catch (error:Error)
        {
            //handle silently
        }
    }
}
}
