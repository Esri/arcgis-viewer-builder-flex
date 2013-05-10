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
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

public class XMLUtil
{
    public static function wrapInCDATA(text:String):XML
    {
        return new XML("<![CDATA[" + text + "]]>");
    }

    //TODO: use across app where applicable
    public static function readXMLFile(xmlFile:File):XML
    {
        var xml:XML;

        if (xmlFile.exists)
        {
            const fileStream:FileStream = new FileStream();
            try
            {
                fileStream.open(xmlFile, FileMode.READ);
                xml = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            }
            catch (e:Error)
            {
                //swallow error
            }
            finally
            {
                fileStream.close();
            }
        }

        return xml;
    }
}
}
