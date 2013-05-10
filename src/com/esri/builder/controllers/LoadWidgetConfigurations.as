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
package com.esri.builder.controllers
{

import com.esri.builder.model.Model;
import com.esri.builder.model.Widget;
import com.esri.builder.model.WidgetType;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.supportClasses.LogUtil;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.logging.ILogger;
import mx.logging.Log;

public final class LoadWidgetConfigurations
{
    private static const LOG:ILogger = LogUtil.createLogger(LoadWidgetConfigurations);

    public function loadWidgetConfigurations():void
    {
        if (Model.instance.appDir)
        {
            if (Log.isInfo())
            {

                LOG.info('Loading widget configurations...');
            }

            var widgetTypes:Array = WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.widgetTypes.source;
            for each (var widgetType:WidgetType in widgetTypes)
            {
                getDirectoryListing(widgetType);
            }

            var layoutWidgetTypes:Array = WidgetTypeRegistryModel.getInstance().layoutWidgetTypeRegistry.widgetTypes.source;
            for each (var layoutWidgetType:WidgetType in layoutWidgetTypes)
            {
                getDirectoryListing(layoutWidgetType);
            }
        }
    }

    private function getDirectoryListing(widgetType:WidgetType):void
    {
        const path:String = "widgets" + File.separator + widgetType.name;
        const dir:File = Model.instance.appDir.resolvePath(path);
        if (Log.isDebug())
        {
            LOG.debug('Looking for xml files in {0}', dir.nativePath);
        }
        if (dir.isDirectory)
        {
            loadWidgetTypeConfigurationList(widgetType, dir.getDirectoryListing());
        }
        else if (Log.isWarn())
        {
            LOG.warn('{0} is not a directory', dir.nativePath);
        }
    }

    private function loadWidgetTypeConfigurationList(widgetType:WidgetType, fileArr:Array):void
    {
        widgetType.widgetList.removeAll();
        const re:RegExp = new RegExp(widgetType.name + 'Widget_?(.*)\.xml');
        for each (var file:File in fileArr)
        {
            if (Log.isDebug())
            {
                LOG.debug('Loading widget name={0}', file.name);
            }
            const tokens:Array = re.exec(file.name);
            if (tokens && tokens.length === 2)
            {
                const name:String = tokens[1];

                const widget:Widget = new Widget();
                widget.name = name.length ? name : widgetType.name;
                widget.label = getLabel(file, widget.name);
                widget.icon = widgetType.iconLocation;
                widget.iconFile = Model.instance.appDir.resolvePath(widget.icon);
                widget.url = widgetType.url;
                widget.config = 'widgets/' + widgetType.name + '/' + file.name;
                widgetType.widgetList.addItem(widget);
                if (Log.isDebug())
                {
                    LOG.debug('Loading widget: {0}', widget.toString());
                }
            }
        }
    }

    private function getLabel(file:File, name:String):String
    {
        var label:String = null;
        const fileStream:FileStream = new FileStream();
        try
        {
            fileStream.open(file, FileMode.READ);
            const configXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            label = configXML.@label;
        }
        catch (e:Error)
        {
            if (Log.isWarn())
            {
                LOG.warn('Error while reading or parsing {0}', file.nativePath);
            }
        }
        finally
        {
            fileStream.close();
        }

        return label ? label : name;
    }
}
}
