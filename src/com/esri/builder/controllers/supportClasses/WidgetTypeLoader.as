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

import com.esri.builder.model.CustomWidgetType;
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

    private var widgetTypeArr:Array = [];
    private var pendingModuleInfos:Array = [];
    private var modulesToLoad:uint;

    public function loadWidgetTypes():void
    {
        if (Log.isInfo())
        {
            LOG.info('Loading modules...');
        }

        var moduleFiles:Array = getModuleFiles(WellKnownDirectories.getInstance().bundledModules)
            .concat(getModuleFiles(WellKnownDirectories.getInstance().customModules));

        //TODO: remove XML files from found SWF files
        modulesToLoad = moduleFiles.length;

        // Load the found modules.
        for each (var moduleFile:File in moduleFiles)
        {
            if (Log.isDebug())
            {
                LOG.debug('loading module {0}', moduleFile.url);
            }

            //we assume XML module files are custom
            if (moduleFile.extension == "xml")
            {
                loadCustomWidgetTypeConfig(moduleFile);
            }
            else if (moduleFile.extension == "swf")
            {
                loadModule(moduleFile);
            }
        }

        checkIfNoMoreModuleInfosLeft();
    }

    private function loadModule(moduleFile:File):void
    {
        var fileBytes:ByteArray = new ByteArray();
        var fileStream:FileStream = new FileStream();
        fileStream.open(moduleFile, FileMode.READ);
        fileStream.readBytes(fileBytes);
        fileStream.close();

        const moduleInfo:IModuleInfo = ModuleManager.getModule(moduleFile.url);
        pendingModuleInfos.push(moduleInfo);
        moduleInfo.addEventListener(ModuleEvent.READY, moduleInfo_readyHandler);
        moduleInfo.addEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);
        moduleInfo.load(ApplicationDomain.currentDomain, null, fileBytes, FlexGlobals.topLevelApplication.moduleFactory);
    }

    public function loadCustomWidgetTypeConfig(configFile:File):void
    {
        var customWidgetType:CustomWidgetType = createCustomWidgetTypeFromConfig(configFile);
        if (customWidgetType)
        {
            WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.addWidgetType(customWidgetType);
        }

        markModuleAsLoaded();
    }

    private function createCustomWidgetTypeFromConfig(configFile:File):CustomWidgetType
    {
        var fileStream:FileStream = new FileStream();
        var customWidgetType:CustomWidgetType;
        try
        {
            fileStream.open(configFile, FileMode.READ);
            const configXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
            customWidgetType = parseCustomWidgetType(configXML);
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

        return customWidgetType;
    }

    private function parseCustomWidgetType(configXML:XML):CustomWidgetType
    {
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

    private function getModuleFiles(directory:File):Array
    {
        var moduleFiles:Array = [];

        if (directory.isDirectory)
        {
            const files:Array = directory.getDirectoryListing();

            for each (var file:File in files)
            {
                if(file.isDirectory)
                {
                    moduleFiles = moduleFiles.concat(getModuleFiles(file));
                }
                else if (isModuleFile(file))
                {
                    moduleFiles.push(file);
                }
            }
        }

        return moduleFiles;
    }

    private function isModuleFile(file:File):Boolean
    {
        const moduleFileName:RegExp = /^.*Module\.(swf|xml)$/;
        return !file.isDirectory && (moduleFileName.test(file.name));
    }

    private function moduleInfo_readyHandler(event:ModuleEvent):void
    {
        var moduleInfo:IModuleInfo = event.currentTarget as IModuleInfo;
        moduleInfo.removeEventListener(ModuleEvent.READY, moduleInfo_readyHandler);
        moduleInfo.removeEventListener(ModuleEvent.ERROR, moduleInfo_errorHandler);

        const builderModule:IBuilderModule = event.module.factory.create() as IBuilderModule;
        if (builderModule)
        {
            var customModulesDirectoryURL:String = WellKnownDirectories.getInstance().customModules.url;
            var isCustomModule:Boolean = (moduleInfo.url.indexOf(customModulesDirectoryURL) > -1);
            const widgetType:WidgetType = isCustomModule ?
                new CustomWidgetType(builderModule) :
                new WidgetType(builderModule);
            widgetTypeArr.push(widgetType);

            if (Log.isDebug())
            {
                LOG.debug('Module {0} is resolved', widgetType.name);
            }

        }

        markModuleAsLoaded();
        removeModuleInfo(moduleInfo);
        checkIfNoMoreModuleInfosLeft();
    }

    private function removeModuleInfo(moduleInfo:IModuleInfo):void
    {
        const index:int = pendingModuleInfos.indexOf(moduleInfo);
        if (index > -1)
        {
            pendingModuleInfos.splice(index, 1);
        }
    }

    private function checkIfNoMoreModuleInfosLeft():void
    {
        if (modulesToLoad === 0)
        {
            sortAndAssignWidgetTypes();
        }
    }

    private function markModuleAsLoaded():void
    {
        modulesToLoad--;
    }

    private function sortAndAssignWidgetTypes():void
    {
        if (Log.isInfo())
        {
            LOG.info('All modules resolved');
        }

        widgetTypeArr.sort(compareWidgetTypes);

        var widgetTypes:Array = widgetTypeArr.filter(widgetTypeFilter);
        for each (var widgetType:WidgetType in widgetTypes)
        {
            WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.addWidgetType(widgetType);
        }

        var layoutWidgetTypes:Array = widgetTypeArr.filter(layoutWidgetTypeFilter);
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

        Model.instance.status = event.errorText;
        BuilderAlert.show(event.errorText,
                          ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        markModuleAsLoaded();
        removeModuleInfo(moduleInfo);
        checkIfNoMoreModuleInfosLeft();
    }
}
}
