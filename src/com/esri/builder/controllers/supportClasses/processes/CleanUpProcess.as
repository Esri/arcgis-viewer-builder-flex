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

import com.esri.builder.controllers.supportClasses.processes.Process;

import flash.errors.IOError;
import flash.filesystem.File;

import mx.resources.ResourceManager;

public class CleanUpProcess extends Process
{
    private var fileOrDirectory:File;

    public function CleanUpProcess(fileOrDirectory:File)
    {
        this.fileOrDirectory = fileOrDirectory;
    }

    override public function execute():void
    {
        try
        {
            if (fileOrDirectory.isDirectory)
            {
                fileOrDirectory.deleteDirectory(true);
            }
            else
            {
                fileOrDirectory.deleteFile();
            }
            dispatchSuccess("Cleaned up finished!");
        }
        catch (ioError:IOError)
        {
            //Directory not found not critical error
            if (ioError.errorID == 3003)
            {
                dispatchSuccess("Cleaned up finished!");
            }
            else
            {
                var ioErrorMessage:String = ResourceManager.getInstance().getString('BuilderStrings', 'appUpgradeProcess.couldNotCleanUp',
                                                                                    [ fileOrDirectory.nativePath, ioError.message ]);
                dispatchFailure(ioErrorMessage);
            }
        }
        catch (error:Error)
        {
            var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings', 'appUpgradeProcess.couldNotCleanUp',
                                                                              [ fileOrDirectory.nativePath, error.message ]);
            dispatchFailure(errorMessage);
        }
    }
}
}
