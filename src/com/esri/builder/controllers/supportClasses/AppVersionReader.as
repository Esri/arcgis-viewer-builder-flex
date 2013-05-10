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
package com.esri.builder.controllers.supportClasses
{

import com.esri.builder.controllers.supportClasses.XMLFileReader;

import flash.filesystem.File;

public class AppVersionReader
{
    private var xmlFileReader:XMLFileReader;

    public function AppVersionReader(xmlFileReader:XMLFileReader)
    {
        this.xmlFileReader = xmlFileReader
    }

    public function readVersionNumber(applicationDirectory:File):Number
    {
        var versionFile:File = applicationDirectory.resolvePath('version.xml');
        return extractAppVersion(versionFile);
    }

    public function extractAppVersion(versionFile:File):Number
    {
        var versionNumber:Number;

        if (versionFile.exists)
        {
            var versionXML:XML = xmlFileReader.readFile(versionFile);
            if (versionXML)
            {
                versionNumber = parseFloat(versionXML.@apiversion);
            }
        }

        return versionNumber;
    }
}
}
