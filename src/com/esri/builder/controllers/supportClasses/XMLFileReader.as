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

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class XMLFileReader
{
    private var fileReader:FileStream;

    public function XMLFileReader(fileReader:FileStream)
    {
        this.fileReader = fileReader;
    }

    public function readFile(xmlFile:File):XML
    {
        if (!fileReader)
        {
            return null;
        }

        XML.ignoreComments = false;
        try
        {
            fileReader.open(xmlFile, FileMode.READ);
            var xml:XML;
            xml = XML(fileReader.readUTFBytes(fileReader.bytesAvailable));
        }
        catch (error:Error)
        {
            //do nothing
        }
        finally
        {
            XML.ignoreComments = true;
            fileReader.close();
        }

        return xml;
    }
}
}
