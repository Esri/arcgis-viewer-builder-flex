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

import com.esri.builder.controllers.supportClasses.WellKnownDirectories;

import flash.filesystem.File;

import modules.IBuilderModule;
import modules.IWidgetModel;
import modules.IWidgetView;

import mx.collections.ArrayList;

public class WidgetType
{
    private var builderModule:IBuilderModule; // Module data content - created after the module is loaded.

    public function WidgetType(builderModule:IBuilderModule)
    {
        this.builderModule = builderModule;
    }

    [Bindable]
    public var widgetList:ArrayList /*<Widget>*/ = new ArrayList();

    [Bindable]
    public function get name():String
    {
        return builderModule.widgetName;
    }

    public function set name(value:String):void
    {
        //setter used for binding
    }

    public function get isManaged():Boolean
    {
        return builderModule.isManaged;
    }

    public function get isOpenByDefault():Boolean
    {
        return builderModule.isOpenByDefault;
    }

    public function get iconLocation():String
    {
        return builderModule.widgetIconLocation;
    }

    public function get label():String
    {
        return builderModule.widgetLabel;
    }

    public function get description():String
    {
        return builderModule.widgetDescription;
    }

    public function get helpURL():String
    {
        return builderModule.widgetHelpURL;
    }

    public function createWidgetView():IWidgetView
    {
        return builderModule.createWidgetView();
    }

    public function createWidgetModel():IWidgetModel
    {
        return builderModule.createWidgetModel();
    }

    public function get url():String
    {
        return "widgets/" + builderModule.widgetName + "/" + builderModule.widgetName + "Widget.swf";
    }

    public function toString():String
    {
        return "WidgetType{builderModule:" + builderModule ? builderModule.widgetName : 'UNK' + "}";
    }

    public function getIconFile():File
    {
        var iconFile:File = WellKnownDirectories.getInstance().customFlexViewer.resolvePath(iconLocation);
        if (!iconFile.exists)
        {
            iconFile = WellKnownDirectories.getInstance().bundledFlexViewer.resolvePath(iconLocation);
        }
        return iconFile;
    }

    public function release():void
    {
        builderModule = null;
    }
}
}
