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

import com.esri.builder.model.WidgetType;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.supportClasses.FileUtil;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.utils.Dictionary;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;

public class StartupWidgetTypeLoader extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(StartupWidgetTypeLoader);

    private var widgetTypeArr:Array = [];
    private var pendingLoaders:Array;

    public function loadWidgetTypes():void
    {
        if (Log.isInfo())
        {
            LOG.info('Loading modules...');
        }

        var moduleFiles:Array = getModuleFiles(WellKnownDirectories.getInstance().bundledModules)
            .concat(getModuleFiles(WellKnownDirectories.getInstance().customModules));

        var swfAndXMLFileMaps:Array = mapFilenameToModuleSWFAndXMLFiles(moduleFiles);

        var processedFileNames:Array = [];
        var loaders:Array = [];

        for each (var moduleFile:File in moduleFiles)
        {
            var fileName:String = FileUtil.getFileName(moduleFile);

            if (Log.isDebug())
            {
                LOG.debug('loading module {0}', fileName);
            }

            if (processedFileNames.indexOf(fileName) == -1)
            {
                processedFileNames.push(fileName);
                loaders.push(new WidgetTypeLoader(swfAndXMLFileMaps[0][fileName],
                                                  swfAndXMLFileMaps[1][fileName]));
            }
        }

        pendingLoaders = loaders.concat();
        for each (var loader:WidgetTypeLoader in loaders)
        {
            loader.addEventListener(WidgetTypeLoaderEvent.LOAD_COMPLETE, loader_loadCompleteHandler);
            loader.addEventListener(WidgetTypeLoaderEvent.LOAD_ERROR, loader_loadErrorHandler);
            loader.load();
        }

        checkIfWidgetTypeLoadersComplete();
    }

    private function mapFilenameToModuleSWFAndXMLFiles(moduleFiles:Array):Array
    {
        var uniqueFileNameToSWF:Dictionary = new Dictionary();
        var uniqueFileNameToXML:Dictionary = new Dictionary();

        for each (var file:File in moduleFiles)
        {
            if (file.extension == "swf")
            {
                uniqueFileNameToSWF[FileUtil.getFileName(file)] = file;
            }
            else if (file.extension == "xml")
            {
                uniqueFileNameToXML[FileUtil.getFileName(file)] = file;
            }
        }

        return [ uniqueFileNameToSWF, uniqueFileNameToXML ];
    }

    private function getModuleFiles(directory:File):Array
    {
        const moduleFileName:RegExp = /^.*Module\.(swf|xml)$/;
        return FileUtil.findMatchingFiles(directory, moduleFileName);
    }

    private function checkIfWidgetTypeLoadersComplete():void
    {
        if (pendingLoaders.length === 0)
        {
            sortAndAssignWidgetTypes();
        }
    }

    private function markModuleAsLoaded(loader:WidgetTypeLoader):void
    {
        var loaderIndex:int = pendingLoaders.indexOf(loader);
        if (loaderIndex > -1)
        {
            pendingLoaders.splice(loaderIndex, 1);
        }
    }

    private function sortAndAssignWidgetTypes():void
    {
        if (Log.isInfo())
        {
            LOG.info('All modules resolved');
        }

        for each (var widgetType:WidgetType in widgetTypeArr)
        {
            if (widgetType.isManaged)
            {
                WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.addWidgetType(widgetType);
            }
            else
            {
                WidgetTypeRegistryModel.getInstance().layoutWidgetTypeRegistry.addWidgetType(widgetType);
            }
        }

        WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.sort();
        WidgetTypeRegistryModel.getInstance().layoutWidgetTypeRegistry.sort();

        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function loader_loadCompleteHandler(event:WidgetTypeLoaderEvent):void
    {
        var loader:WidgetTypeLoader = event.currentTarget as WidgetTypeLoader;
        loader.removeEventListener(WidgetTypeLoaderEvent.LOAD_COMPLETE, loader_loadCompleteHandler);
        loader.removeEventListener(WidgetTypeLoaderEvent.LOAD_ERROR, loader_loadErrorHandler);

        var widgetType:WidgetType = event.widgetType;

        if (Log.isDebug())
        {
            LOG.debug('Module {0} is resolved', widgetType.name);
        }

        widgetTypeArr.push(widgetType);
        markModuleAsLoaded(loader);
        checkIfWidgetTypeLoadersComplete();
    }

    private function loader_loadErrorHandler(event:WidgetTypeLoaderEvent):void
    {
        var loader:WidgetTypeLoader = event.currentTarget as WidgetTypeLoader;
        loader.removeEventListener(WidgetTypeLoaderEvent.LOAD_COMPLETE, loader_loadCompleteHandler);
        loader.removeEventListener(WidgetTypeLoaderEvent.LOAD_ERROR, loader_loadErrorHandler);

        var errorMessage:String = ResourceManager.getInstance().getString('BuilderStrings',
                                                                          'importWidgetProcess.couldNotLoadCustomWidgets',
                                                                          [ loader.name ]);
        if (Log.isDebug())
        {
            LOG.debug(errorMessage);
        }

        BuilderAlert.show(errorMessage,
                          ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        markModuleAsLoaded(loader);
        checkIfWidgetTypeLoadersComplete();
    }
}
}
