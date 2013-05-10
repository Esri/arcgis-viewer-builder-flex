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
package com.esri.builder.model
{

import com.esri.builder.supportClasses.URLUtil;

import flash.filesystem.File;

[Bindable]
public class ViewerApp
{
    public var version:Number;
    public var directory:File;

    private var baseURL:String;
    private var lastModifiedDate:Date;

    public function ViewerApp(version:Number, directory:File, baseURL:String)
    {
        this.version = version;
        this.directory = directory;
        this.baseURL = baseURL;
    }

    public function get label():String
    {
        return directory.name;
    }

    public function set label(value:String):void
    {
        // NOOP - just there for [Bindable]
    }

    public function get modifiedDate():Date
    {
        try
        {
            lastModifiedDate = directory.modificationDate;
        }
        catch (error:Error)
        {
            //ignore
        }

        return lastModifiedDate;
    }

    public function set modifiedDate(value:Date):void
    {
        // NOOP - just there for [Bindable]
    }

    public function get url():String
    {
        return baseURL + '/' + URLUtil.encode(directory.name) + '/';
    }
}
}
