////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2016 Esri. All Rights Reserved.
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

import com.esri.builder.model.CustomWidgetType;
import com.esri.builder.model.WidgetType;
import com.esri.builder.supportClasses.FileUtil;
import com.esri.builder.supportClasses.LogUtil;

import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import modules.IBuilderModule;
import modules.supportClasses.CustomXMLModule;

import mx.core.FlexGlobals;
import mx.events.ModuleEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;

public class WidgetTypeLoader extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(WidgetTypeLoader);

    internal static var loadedModuleInfos:Array = [];

    private var swf:File;
    private var config:File;

    //need reference when loading to avoid being garbage collected before load completes
    private var moduleInfo:IModuleInfo;

    //requires either swf or config
    public function WidgetTypeLoader(swf:File = null, config:File = null)
    {
        this.swf = swf;
        this.config = config;
    }

    public function get name():String
    {
        var fileName:String;

        if (swf && swf.exists)
        {
            fileName = FileUtil.getFileName(swf);
        }
        else if (config && config.exists)
        {
            fileName = FileUtil.getFileName(config);
        }

        return fileName;
    }

    public function load():void
    {
        if (swf && swf.exists)
        {
            loadModule();
        }
        else if (config && config.exists)
        {
            loadConfigModule();
        }
        else
        {
            dispatchError();
        }
    }

    private function loadConfigModule():void
    {
        if (Log.isInfo())
        {
            LOG.info('Loading XML module: {0}', config.url);
        }

        var moduleConfig:XML = readModuleConfig(config);
        if (moduleConfig)
        {
            var customWidgetType:CustomWidgetType = parseCustomWidgetType(moduleConfig);
            if (customWidgetType)
            {
                dispatchComplete(customWidgetType);
                return;
            }
        }

        dispatchError();
    }

    private function loadModule():void
    {
        if (Log.isInfo())
        {
            LOG.info('Loading SWF module: {0}', swf.url);
        }

        moduleInfo = ModuleManager.getModule(swf.url);

        if (moduleInfo.ready)
        {
            if (Log.isInfo())
            {
                LOG.info('Unloading module: {0}', swf.url);
            }

            moduleInfo.addEventListener(ModuleEvent.UNLOAD, moduleInfo_unloadHandler);
            moduleInfo.release();
            moduleInfo.unload();
        }
        else
        {
            if (Log.isInfo())
            {
                LOG.info('Loading module: {0}', swf.url);
            }

            var fileBytes:ByteArray = new ByteArray();
            var fileStream:FileStream = new FileStream();
            fileStream.open(swf, FileMode.READ);
            fileStream.readBytes(fileBytes);
            fileStream.close();

            //Use ModuleEvent.PROGRESS instead of ModuleEvent.READY to avoid the case where the latter is never dispatched.
            moduleInfo.addEventListener(ModuleEvent.PROGRESS, moduleInfo_progressHandler);
            moduleInfo.addEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);
            moduleInfo.load(null, null, fileBytes, FlexGlobals.topLevelApplication.moduleFactory);
        }
    }

    private function moduleInfo_progressHandler(event:ModuleEvent):void
    {
        if (event.bytesLoaded == event.bytesTotal)
        {
            var moduleInfo:IModuleInfo = event.currentTarget as IModuleInfo;
            moduleInfo.removeEventListener(ModuleEvent.PROGRESS, moduleInfo_progressHandler);
            moduleInfo.removeEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);
            FlexGlobals.topLevelApplication.callLater(processModuleInfo, [ moduleInfo ]);
        }
    }

    private function moduleInfo_unloadHandler(event:ModuleEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info('Module unloaded: {0}', swf.url);
        }

        var moduleInfo:IModuleInfo = event.module;
        moduleInfo.removeEventListener(ModuleEvent.UNLOAD, moduleInfo_unloadHandler);
        var moduleInfoIndex:int = loadedModuleInfos.indexOf(moduleInfo);
        if (moduleInfoIndex > -1)
        {
            loadedModuleInfos.splice(moduleInfoIndex, 1);
        }
        this.moduleInfo = null;
        FlexGlobals.topLevelApplication.callLater(loadModule);
    }

    private function processModuleInfo(moduleInfo:IModuleInfo):void
    {
        if (Log.isInfo())
        {
            LOG.info('Module loaded: {0}', swf.url);
        }

        if (config && config.exists)
        {
            if (Log.isInfo())
            {
                LOG.info('Reading module config: {0}', config.url);
            }
            var moduleConfig:XML = readModuleConfig(config);
        }


        const builderModule:IBuilderModule = moduleInfo.factory.create() as IBuilderModule;
        if (builderModule)
        {
            if (Log.isInfo())
            {
                LOG.info('Widget type created for module: {0}', swf.url);
            }
            var widgetType:WidgetType = getWidgetType(moduleInfo, builderModule, moduleConfig);
        }

        loadedModuleInfos.push(moduleInfo);
        this.moduleInfo = null;
        dispatchComplete(widgetType);
    }

    private function dispatchComplete(widgetType:WidgetType):void
    {
        if (Log.isInfo())
        {
            LOG.info('Module load complete: {0}', name);
        }

        dispatchEvent(new WidgetTypeLoaderEvent(WidgetTypeLoaderEvent.LOAD_COMPLETE, widgetType));
    }

    private function getWidgetType(moduleInfo:IModuleInfo, builderModule:IBuilderModule, moduleConfig:XML):WidgetType
    {
        var customModulesDirectoryURL:String = WellKnownDirectories.getInstance().customModules.url;
        var isCustomModule:Boolean = (moduleInfo.url.indexOf(customModulesDirectoryURL) > -1);
        if (moduleConfig)
        {
            var configXML:XML = moduleConfig.configuration[0];
            var version:String = moduleConfig.widgetversion[0];
        }

        return isCustomModule ?
            new CustomWidgetType(builderModule, version, configXML) :
            new WidgetType(builderModule);
    }

    private function readModuleConfig(configFile:File):XML
    {
        var configXML:XML;

        var fileStream:FileStream = new FileStream();
        try
        {
            fileStream.open(configFile, FileMode.READ);
            configXML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
        }
        catch (e:Error)
        {
            //ignore
            if (Log.isInfo())
            {
                LOG.info('Could not read module config: {0}', e.toString());
            }
        }
        finally
        {
            fileStream.close();
        }

        return configXML;
    }

    private function moduleInfo_errorHandler(event:ModuleEvent):void
    {
        var moduleInfo:IModuleInfo = event.module;
        moduleInfo.removeEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);
        moduleInfo.removeEventListener(ModuleEvent.PROGRESS, moduleInfo_progressHandler);
        this.moduleInfo = null;
        dispatchError();
    }

    private function dispatchError():void
    {
        if (Log.isInfo())
        {
            LOG.info('Module load failed: {0}', name);
        }

        dispatchEvent(new WidgetTypeLoaderEvent(WidgetTypeLoaderEvent.LOAD_ERROR));
    }

    private function parseCustomWidgetType(configXML:XML):CustomWidgetType
    {
        if (Log.isInfo())
        {
            LOG.info('Creating widget type from XML: {0}', configXML);
        }

        var customModule:CustomXMLModule = new CustomXMLModule();
        customModule.widgetName = configXML.name;
        customModule.isOpenByDefault = (configXML.openbydefault == 'true');

        var widgetLabel:String = configXML.label[0];
        var widgetDescription:String = configXML.description[0];
        var widgetHelpURL:String = configXML.helpurl[0];
        var widgetConfiguration:XML = configXML.configuration[0] ? configXML.configuration[0] : <configuration/>;
        var widgetVersion:String = configXML.widgetversion[0];

        customModule.widgetIconLocation = createWidgetIconPath(configXML.icon[0], customModule.widgetName);
        customModule.widgetLabel = widgetLabel ? widgetLabel : customModule.widgetName;
        customModule.widgetDescription = widgetDescription ? widgetDescription : "";
        customModule.widgetHelpURL = widgetHelpURL ? widgetHelpURL : "";

        return new CustomWidgetType(customModule, widgetVersion, widgetConfiguration);
    }

    private function createWidgetIconPath(iconPath:String, widgetName:String):String
    {
        var widgetIconPath:String;

        if (iconPath)
        {
            widgetIconPath = "widgets/" + widgetName + "/" + iconPath;
        }
        else
        {
            widgetIconPath = "assets/images/i_widget.png";
        }

        return widgetIconPath;
    }
}
}
