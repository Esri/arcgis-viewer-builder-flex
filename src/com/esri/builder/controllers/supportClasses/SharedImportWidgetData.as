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

public class SharedImportWidgetData
{
    private var _zippedWidgetFile:File;

    public function get zippedWidgetFile():File
    {
        return _zippedWidgetFile;
    }

    public function set zippedWidgetFile(value:File):void
    {
        _zippedWidgetFile = value;
    }

    private var _unzipWidgetWorkspace:File;

    public function get unzipWidgetWorkspace():File
    {
        return _unzipWidgetWorkspace;
    }

    public function set unzipWidgetWorkspace(value:File):void
    {
        _unzipWidgetWorkspace = value;
    }

    private var _customWidgetFile:File;

    public function get customWidgetFile():File
    {
        return _customWidgetFile;
    }

    public function set customWidgetFile(value:File):void
    {
        _customWidgetFile = value;
    }

    private var _customWidgetName:String;

    public function get customWidgetName():String
    {
        return _customWidgetName;
    }

    public function set customWidgetName(value:String):void
    {
        _customWidgetName = value;
    }

    private var _customFlexViewerDirectory:File;

    public function get customFlexViewerDirectory():File
    {
        return _customFlexViewerDirectory;
    }

    public function set customFlexViewerDirectory(value:File):void
    {
        _customFlexViewerDirectory = value;
    }

    private var _customModulesDirectory:File;

    public function get customModulesDirectory():File
    {
        return _customModulesDirectory;
    }

    public function set customModulesDirectory(value:File):void
    {
        _customModulesDirectory = value;
    }

    private var _customWidgetModuleConfigFile:File;

    public function get customWidgetModuleConfigFile():File
    {
        return _customWidgetModuleConfigFile;
    }

    public function set customWidgetModuleConfigFile(value:File):void
    {
        _customWidgetModuleConfigFile = value;
    }

    private var _customWidgetModuleFile:File;

    public function get customWidgetModuleFile():File
    {
        return _customWidgetModuleFile;
    }

    public function set customWidgetModuleFile(value:File):void
    {
        _customWidgetModuleFile = value;
    }

    private var _metaFile:File;

    public function get metaFile():File
    {
        return _metaFile;
    }

    public function set metaFile(value:File):void
    {
        _metaFile = value;
    }

    private var _replacedExistingCustomWidget:Boolean;

    public function get replacedExistingCustomWidget():Boolean
    {
        return _replacedExistingCustomWidget;
    }

    public function set replacedExistingCustomWidget(value:Boolean):void
    {
        _replacedExistingCustomWidget = value;
    }

    private var _customWidgetVersion:String;

    public function get customWidgetVersion():String
    {
        return _customWidgetVersion;
    }

    public function set customWidgetVersion(value:String):void
    {
        _customWidgetVersion = value;
    }
}
}
