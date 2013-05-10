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

import com.esri.builder.controllers.supportClasses.HTMLWrapperUpdater;
import com.esri.builder.controllers.supportClasses.WellKnownDirectories;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.model.ViewerApp;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;
import com.esri.builder.views.popups.CreateApplicationPopUp;

import flash.display.DisplayObject;
import flash.filesystem.File;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.PopUpManager;
import mx.resources.ResourceManager;
import mx.utils.StringUtil;

public final class CreateAppController
{
    private static const LOG:ILogger = LogUtil.createLogger(CreateAppController);

    private var createAppPopUp:CreateApplicationPopUp;

    public function CreateAppController()
    {
        AppEvent.addListener(AppEvent.CREATE_APP, onCreateApp, false, 0, true);
    }

    public var loadWidgetConfigurations:LoadWidgetConfigurations;

    private function onCreateApp(event:AppEvent):void
    {
        createAppPopUp = new CreateApplicationPopUp();
        createAppPopUp.addEventListener(CloseEvent.CLOSE, createPopUp_closeHandler, false, 0, true);
        PopUpManager.addPopUp(createAppPopUp, FlexGlobals.topLevelApplication as DisplayObject, true);
        PopUpManager.centerPopUp(createAppPopUp);
        AppEvent.addListener(AppEvent.CREATE_EXECUTE, onCreateExecute, false, 0, true);
    }

    protected function createPopUp_closeHandler(event:CloseEvent):void
    {
        closePopUp();
    }

    private function closePopUp():void
    {
        if (createAppPopUp)
        {
            PopUpManager.removePopUp(createAppPopUp);
            createAppPopUp = null;
            AppEvent.removeListener(AppEvent.CREATE_EXECUTE, onCreateExecute);
        }
    }

    private function onCreateExecute(event:AppEvent):void
    {
        closePopUp();
        createExecute(event.data as String);
    }

    private function createExecute(appName:String):void
    {
        const appDir:File = Model.instance.baseDir.resolvePath(appName);
        if (Log.isInfo())
        {
            LOG.info('Creating application directory {0}', appDir.nativePath);
        }

        if (appDir.exists)
        {
            const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'createController.appExistsText', [ appName ]);
            const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'createController.appExistsTitle');
            BuilderAlert.show(text, title, Alert.YES | Alert.NO, null, closeHandler, null, Alert.NO);
            function closeHandler(event:CloseEvent):void
            {
                if (event.detail === Alert.YES)
                {
                    createApplication(appDir, appName);
                }
            }
        }
        else
        {
            createApplication(appDir, appName);
        }
    }

    private function createApplication(appDir:File, appName:String):void
    {
        try
        {
            appDir.createDirectory();

            Model.instance.appName = appName;
            Model.instance.appDir = appDir;
            Model.instance.status = ResourceManager.getInstance().getString('BuilderStrings', 'createController.status', [ appName ]);

            copyFlexViewer();

        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Cannot create directory: {0}', e.message);
            }
            BuilderAlert.show(e.message.toString(), ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
    }

    private function copyFlexViewer():void
    {
        if (Log.isDebug())
        {
            LOG.debug('Copying flex viewer to {0}', Model.instance.appDir.nativePath);
        }
        Model.instance.status = ResourceManager.getInstance().getString('BuilderStrings', 'settings.creatingFlexViewer');
        m_doLaterCounter = 5;

        FlexGlobals.topLevelApplication.callLater(doLater);
    }

    private var m_doLaterCounter:int;

    private function doLater():void
    {
        if (m_doLaterCounter--)
        {
            FlexGlobals.topLevelApplication.callLater(doLater);
        }
        else
        {
            copyFlexViewerLater();
        }
    }

    private function copyFlexViewerLater():void
    {
        var bundledFlexViewer:File = WellKnownDirectories.getInstance().bundledFlexViewer;
        if (!bundledFlexViewer.exists || !bundledFlexViewer.isDirectory)
        {
            const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'createApp.noFlexViewerText');
            const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'createApp.noFlexViewerTitle');
            Model.instance.status = text;
            BuilderAlert.show(text, title);
            return;
        }
        bundledFlexViewer.copyTo(Model.instance.appDir, true);
        copyConfigFile();
        updateHTMLWrapper(Model.instance.appDir);

        Model.instance.status = '';
        AppEvent.dispatch(AppEvent.APP_CREATED);

        AppEvent.dispatch(AppEvent.EDIT_APP,
                          new ViewerApp(Model.SUPPORTED_VIEWER_VERSION,
                                        Model.instance.appDir,
                                        Model.instance.webServerURL));
    }

    private function updateHTMLWrapper(appDir:File):void
    {
        var htmlWrapperUpdater:HTMLWrapperUpdater = new HTMLWrapperUpdater();
        htmlWrapperUpdater.updateHTMLWrapper(appDir);
    }

    private function copyConfigFile():void
    {
        var localizedConfigPath:String = StringUtil.substitute('configs/{0}/config.xml', Model.instance.locale);

        // Override FlexViewer/config.xml with built-in config.xml to make it the default
        const localizedConfigFile:File = File.applicationDirectory.resolvePath(localizedConfigPath);
        if (localizedConfigFile.exists)
        {
            const originalConfigFile:File = Model.instance.appDir.resolvePath('config.xml');
            if (Log.isDebug())
            {
                LOG.debug('Overriding {0}', originalConfigFile.nativePath);
            }
            localizedConfigFile.copyTo(originalConfigFile, true);
        }
        else if (Log.isWarn())
        {
            LOG.warn('Cannot resolve {0}', localizedConfigFile.nativePath);
        }
    }
}
}
