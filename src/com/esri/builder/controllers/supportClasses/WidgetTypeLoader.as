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

import com.esri.builder.model.Model;
import com.esri.builder.model.WidgetType;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;

import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

import modules.IBuilderModule;
import modules.supportClasses.CustomXMLModule;

import mx.core.FlexGlobals;
import mx.events.ModuleEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;
import mx.resources.ResourceManager;

public class WidgetTypeLoader extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(WidgetTypeLoader);

    private var _moduleInfoArr:Array = [];
    private var _widgetTypeArr:Array = [];

    public function loadWidgetTypes():void
    {
        if (Log.isInfo())
        {
            LOG.info('Loading modules...');
        }

        const modulesDirectory:File = WellKnownDirectories.getInstance().bundledModules;
        loadCustomWidgetTypes(WellKnownDirectories.getInstance().customModules);

        const swfList:Array = getModuleSWFs(modulesDirectory);

        // Load the found modules.
        swfList.forEach(function(file:File, index:int, source:Array):void
        {
            if (Log.isDebug())
            {
                LOG.debug('loading module {0}', file.url);
            }

            var fileBytes:ByteArray = new ByteArray();
            var fileStream:FileStream = new FileStream();
            fileStream.open(file, FileMode.READ);
            fileStream.readBytes(fileBytes);
            fileStream.close();

            const moduleInfo:IModuleInfo = ModuleManager.getModule(file.url);
            _moduleInfoArr.push(moduleInfo);
            moduleInfo.addEventListener(ModuleEvent.READY, moduleInfo_readyHandler);
            moduleInfo.addEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);
            moduleInfo.load(ApplicationDomain.currentDomain, null, fileBytes, FlexGlobals.topLevelApplication.moduleFactory);
        });

        checkIfNoMoreModuleInfosLeft();
    }

    private function loadCustomWidgetTypes(modulesDirectory:File):void
    {
        var moduleDirectoryContents:Array = modulesDirectory.getDirectoryListing();
        for each (var fileOrFolder:File in moduleDirectoryContents)
        {
            loadCustomWidgetTypeConfig(fileOrFolder);
        }
    }

    public function loadCustomWidgetTypeConfig(configFile:File):void
    {
        const customModuleFileName:RegExp = /^.*Module\.xml$/;
        if (!configFile.isDirectory && customModuleFileName.test(configFile.name))
        {
            var customModule:IBuilderModule = createCustomModuleFromConfig(configFile);
            if (customModule)
            {
                WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.addWidgetType(new WidgetType(customModule));
            }
        }
    }

    private function createCustomModuleFromConfig(configFile:File):IBuilderModule
    {
        var fileStream:FileStream = new FileStream();
        var customModule:CustomXMLModule;
        try
        {
            fileStream.open(configFile, FileMode.READ);
            const configXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            customModule = parseCustomModule(configXML);
        }
        catch (e:Error)
        {
            if (Log.isWarn())
            {
                LOG.warn('Error creating custom module {0}', configFile.nativePath);
            }
        }
        finally
        {
            fileStream.close();
        }

        return customModule;
    }

    private function parseCustomModule(configXML:XML):CustomXMLModule
    {
        var customModule:CustomXMLModule = new CustomXMLModule();
        customModule.widgetName = configXML.name;
        customModule.isOpenByDefault = (configXML.openbydefault == 'true');

        var widgetLabel:String = configXML.label[0];
        var widgetDescription:String = configXML.description[0];
        var widgetHelpURL:String = configXML.helpurl[0];
        var widgetConfiguration:String = configXML.configuration[0];
        var widgetVersion:String = configXML.widgetversion[0];

        customModule.widgetIconLocation = createWidgetIconPath(configXML.icon[0], customModule.widgetName);
        customModule.widgetLabel = widgetLabel ? widgetLabel : customModule.widgetName;
        customModule.widgetVersion = widgetVersion;
        customModule.widgetDescription = widgetDescription ? widgetDescription : "";
        customModule.widgetHelpURL = widgetHelpURL ? widgetHelpURL : "";
        customModule.configXML = widgetConfiguration ? widgetConfiguration : "<configuration></configuration>";

        return customModule;
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

    /* Finds module SWF files at the parent-directory level */
    private function getModuleSWFs(directory:File):Array
    {
        var swfFiles:Array = [];

        if (directory.isDirectory)
        {
            const moduleFileName:RegExp = /^.*Module\.swf$/;
            const files:Array = directory.getDirectoryListing();

            for each (var file:File in files)
            {
                if (!file.isDirectory && moduleFileName.test(file.name))
                {
                    swfFiles.push(file);
                }
            }
        }

        return swfFiles;
    }

    private function moduleInfo_readyHandler(event:ModuleEvent):void
    {
        var moduleInfo:IModuleInfo = event.currentTarget as IModuleInfo;
        moduleInfo.removeEventListener(ModuleEvent.READY, moduleInfo_readyHandler);
        moduleInfo.removeEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);

        const builderModule:IBuilderModule = event.module.factory.create() as IBuilderModule;
        if (builderModule)
        {
            const widgetType:WidgetType = new WidgetType(builderModule);
            _widgetTypeArr.push(widgetType);

            // Resolve the object
            //            FlexGlobals.topLevelApplication.registry.resolve(builderModule, ApplicationDomain.currentDomain);
            if (Log.isDebug())
            {
                LOG.debug('Module {0} is resolved', widgetType.name);
            }

            removeModuleInfo(event.module);
        }
    }

    private function removeModuleInfo(moduleInfo:IModuleInfo):void
    {
        const index:int = _moduleInfoArr.indexOf(moduleInfo);
        if (index > -1)
        {
            _moduleInfoArr.splice(index, 1);
            checkIfNoMoreModuleInfosLeft();
        }
    }

    private function checkIfNoMoreModuleInfosLeft():void
    {
        if (_moduleInfoArr.length === 0)
        {
            sortAndAssignWidgetTypes();
        }
    }

    private function sortAndAssignWidgetTypes():void
    {
        if (Log.isInfo())
        {
            LOG.info('All modules resolved');
        }

        _widgetTypeArr.sort(compareWidgetTypes);

        var widgetTypes:Array = _widgetTypeArr.filter(widgetTypeFilter);
        for each (var widgetType:WidgetType in widgetTypes)
        {
            WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.addWidgetType(widgetType);
        }

        var layoutWidgetTypes:Array = _widgetTypeArr.filter(layoutWidgetTypeFilter);
        for each (var layoutWidgetType:WidgetType in layoutWidgetTypes)
        {
            WidgetTypeRegistryModel.getInstance().layoutWidgetTypeRegistry.addWidgetType(layoutWidgetType);
        }

        function widgetTypeFilter(item:WidgetType, index:int, source:Array):Boolean
        {
            return item.isManaged;
        }
        function layoutWidgetTypeFilter(item:WidgetType, index:int, source:Array):Boolean
        {
            return !item.isManaged;
        }

        dispatchEvent(new WidgetTypeLoaderEvent(WidgetTypeLoaderEvent.LOAD_TYPES_COMPLETE));
    }

    private function compareWidgetTypes(lhs:WidgetType, rhs:WidgetType):int
    {
        const lhsLabel:String = lhs.label.toLowerCase();
        const rhsLabel:String = rhs.label.toLowerCase();
        if (lhsLabel < rhsLabel)
        {
            return -1;
        }
        if (lhsLabel > rhsLabel)
        {
            return 1;
        }
        return 0;
    }

    private function moduleInfo_errorHandler(event:ModuleEvent):void
    {
        if (Log.isWarn())
        {
            LOG.warn('Module error: {0}', event.errorText);
        }

        var moduleInfo:IModuleInfo = event.currentTarget as IModuleInfo;
        moduleInfo.removeEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);
        moduleInfo.removeEventListener(ModuleEvent.READY, moduleInfo_readyHandler);

        removeModuleInfo(event.module);
        Model.instance.status = event.errorText;
        BuilderAlert.show(event.errorText,
                          ResourceManager.getInstance().getString('BuilderStrings', 'error'));
    }
}
}
