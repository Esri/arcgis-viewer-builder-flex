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

public class WellKnownDirectories
{
    private const FLEX_VIEWER_DIR_NAME:String = "flexviewer";
    private const MODULES_DIR_NAME:String = "modules";

    public function get bundledFlexViewer():File
    {
        return File.applicationDirectory.resolvePath(FLEX_VIEWER_DIR_NAME);
    }

    public function get bundledModules():File
    {
        return File.applicationDirectory.resolvePath(MODULES_DIR_NAME);
    }

    public function get customFlexViewer():File
    {
        return File.applicationStorageDirectory.resolvePath(FLEX_VIEWER_DIR_NAME);
    }

    public function get customModules():File
    {
        return File.applicationStorageDirectory.resolvePath(MODULES_DIR_NAME);
    }

    //SINGLETON
    private static var instance:WellKnownDirectories;

    public function WellKnownDirectories(singletonEnforcer:SingletonEnforcer)
    {
        if (!singletonEnforcer)
        {
            throw new Error("Class should not be instantiated - use getInstance()");
        }
    }

    public static function getInstance():WellKnownDirectories
    {
        if (!instance)
        {
            instance = new WellKnownDirectories(new SingletonEnforcer());
        }

        return instance;
    }
}
}

class SingletonEnforcer
{
}
