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

import com.esri.ags.components.IdentityManager;
import com.esri.builder.components.LogFileTarget;
import com.esri.builder.components.ToolTip;
import com.esri.builder.controllers.supportClasses.Settings;
import com.esri.builder.controllers.supportClasses.WellKnownDirectories;
import com.esri.builder.controllers.supportClasses.WidgetTypeLoader;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.controllers.supportClasses.MachineDisplayName;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalModel;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;
import com.esri.builder.views.popups.UnknownErrorPopUp;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.UncaughtErrorEvent;
import flash.filesystem.File;
import flash.net.SharedObject;
import flash.net.URLRequestDefaults;
import flash.system.Capabilities;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.managers.ToolTipManager;
import mx.resources.ResourceManager;
import mx.rpc.AsyncResponder;

import spark.components.WindowedApplication;

public final class ApplicationCompleteController
{
    private static const LOG:ILogger = LogUtil.createLogger(ApplicationCompleteController);

    private var widgetTypeLoader:WidgetTypeLoader;

    private var startupSettings:Settings;

    public function ApplicationCompleteController()
    {
        AppEvent.addListener(AppEvent.APPLICATION_COMPLETE, onApplicationComplete, false, 0, true);
    }

    private function onApplicationComplete(event:AppEvent):void
    {
        applicationComplete(event.data as WindowedApplication);
        Model.instance.config.isDirty = false;
    }

    private function applicationComplete(app:WindowedApplication):void
    {
        if (Log.isInfo())
        {
            LOG.info('Starting up application.');
        }

        exportDependenciesToAppStorage();
        loadUserPreferences();
        loadWebMapSearchHistory();
        // Disable HTTP cache for HTML component
        URLRequestDefaults.cacheResponse = false;

        // Setup some XML global properties
        XML.ignoreComments = true;
        XML.ignoreWhitespace = true;
        XML.prettyIndent = 4;

        IdentityManager.instance.enabled = true;

        ToolTipManager.toolTipClass = com.esri.builder.components.ToolTip;

        // Can only have access to 'loaderInfo' when the app is complete.
        app.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);

        widgetTypeLoader = new WidgetTypeLoader();
        widgetTypeLoader.addEventListener(Event.COMPLETE, widgetTypeLoader_completeHandler);
        widgetTypeLoader.loadWidgetTypes();
    }

    private function exportDependenciesToAppStorage():void
    {
        try
        {
            if (Log.isInfo())
            {
                LOG.info('Creating required folders.');
            }

            WellKnownDirectories.getInstance().customFlexViewer.createDirectory();
            WellKnownDirectories.getInstance().customModules.createDirectory();
        }
        catch (error:Error)
        {
            BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'startup.couldNotCreateCustomDirectories'), ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
    }

    private function loadUserPreferences():void
    {
        if (Log.isInfo())
        {
            LOG.info('Loading user preferences...');
        }

        migratePreviousSettingsFolder();
        const so:SharedObject = SharedObject.getLocal(Model.USER_PREF);

        startupSettings = new Settings();

        startupSettings.webServerURL = so.data.baseURL;
        startupSettings.webServerFolder = so.data.baseLoc;
        startupSettings.locale = so.data.locale ? so.data.locale : getPreferredLocale();
        startupSettings.bingKey = so.data.bingKey;
        startupSettings.proxyURL = so.data.httpProxy;

        if (so.data.hasOwnProperty("userPortalURL"))
        {
            //updated property for v3.1+
            startupSettings.portalURL = so.data.userPortalURL;
            startupSettings.geocodeURL = so.data.geocodeURL;
            startupSettings.directionsURL = so.data.directionsURL;
            startupSettings.printTaskURL = so.data.printTaskURL;
        }
        else
        {
            startupSettings.portalURL = (so.data.portalURL) ? so.data.portalURL : PortalModel.DEFAULT_PORTAL_URL;
        }

        if (so.data.hasOwnProperty("userGeometryServiceURL"))
        {
            //updated property for v3.1+
            startupSettings.geometryServiceURL = so.data.userGeometryServiceURL;
        }
        else
        {
            startupSettings.geometryServiceURL = so.data.userGeometryServiceURL = (so.data.geometryServiceURL) ? so.data.geometryServiceURL : "http://tasks.arcgisonline.com/ArcGIS/rest/services/Geometry/GeometryServer";
        }

        if (so.data.hasOwnProperty("isTutorialModeEnabled"))
        {
            startupSettings.isTutorialModeEnabled = so.data.isTutorialModeEnabled;
        }
        else if (so.data.tutorialModeSettings)
        {
            startupSettings.isTutorialModeEnabled = so.data.tutorialModeSettings.isTutorialModeEnabled;
        }

        so.close();

        if (!startupSettings.webServerFolder)
        {
            if (Capabilities.os.toLowerCase().indexOf('win') > -1)
            {
                startupSettings.webServerFolder = 'C:\\inetpub\\wwwroot\\flexviewers';
            }
            else if (Capabilities.os.toLowerCase().indexOf('mac') > -1)
            {
                startupSettings.webServerFolder = File.userDirectory.nativePath + '/Sites/flexviewers';
            }
            else if (Capabilities.os.toLowerCase().indexOf('linux') > -1)
            {
                startupSettings.webServerFolder = '/var/httpd/wwwroot/flexviewers'; // TODO - check this !!
            }
        }

        if (startupSettings.webServerURL)
        {
            applySettings();
        }
        else
        {
            tryGetHostName();
        }
    }

    private function migratePreviousSettingsFolder():void
    {
        var previousBuilderSettingsFolder:File =
            File.applicationStorageDirectory.resolvePath("#SharedObjects/AppBuilder.swf/");

        if (!previousBuilderSettingsFolder.exists)
        {
            return;
        }

        var filesOrFolders:Array = previousBuilderSettingsFolder.getDirectoryListing();

        if (filesOrFolders.length == 0)
        {
            return;
        }

        if (Log.isInfo())
        {
            LOG.info('Transferring previous settings folder');
        }

        var currentBuilderSettingsFolder:File =
            File.applicationStorageDirectory.resolvePath("#SharedObjects/Builder.swf/");

        try
        {
            for each (var fileOrFolder:File in filesOrFolders)
            {
                if (Log.isInfo())
                {
                    LOG.info('Transferring {0}', fileOrFolder.name);
                }
                fileOrFolder.moveTo(currentBuilderSettingsFolder.resolvePath(fileOrFolder.name),
                                    true);
            }
        }
        catch (error:Error)
        {
            if (Log.isInfo())
            {
                LOG.info('Could not transfer previous settings folder: {0} - {1}',
                         error.errorID, error.toString());
            }
        }
    }

    private function applySettings():void
    {
        Model.instance.importSettings(startupSettings);
        startupSettings = null;
    }

    private function tryGetHostName():void
    {
        MachineDisplayName.getInstance().resolve(new AsyncResponder(result, fault));

        function result(hostname:String, token:Object):void
        {
            initBaseURL(hostname.toLowerCase());
            applySettings();
        }

        function fault(fault:Object, token:Object):void
        {
            initBaseURL("localhost");
            applySettings();
        }
    }

    private function initBaseURL(hostname:String):void
    {
        if (Capabilities.os.toLowerCase().indexOf('win') > -1)
        {
            startupSettings.webServerURL = 'http://' + hostname + '/flexviewers';
        }
        else if (Capabilities.os.toLowerCase().indexOf('mac') > -1)
        {
            startupSettings.webServerURL = 'http://' + hostname + '/~' + File.userDirectory.name + '/flexviewers';
        }
        else if (Capabilities.os.toLowerCase().indexOf('linux') > -1)
        {
            startupSettings.webServerURL = 'http://' + hostname + '/flexviewers'; // TODO - check this !!
        }
    }

    private function getPreferredLocale():String
    {
        const preferredLocales:Array = ResourceManager.getInstance().getPreferredLocaleChain();
        return (preferredLocales.length > 0) ? preferredLocales[0] : 'en_US';
    }

    private function loadWebMapSearchHistory():void
    {
        if (Log.isInfo())
        {
            LOG.info("Loading web map search history");
        }

        const so:SharedObject = SharedObject.getLocal(Model.USER_PREF);
        var historyString:String = so.data.webMapSearchHistory;
        if (historyString != null)
        {
            Model.instance.webMapSearchHistory = historyString.split("##");
        }
        so.close();
    }

    private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
    {
        event.preventDefault();

        if (Log.isFatal())
        {
            if (event.error is Error) //could be ErrorEvent
            {
                LOG.fatal('Uncaught error: {0}', event.error.getStackTrace());
            }
        }

        const logFile:File = File.applicationStorageDirectory.resolvePath(LogFileTarget.LOG_FILE_NAME);
        const errorContent:String = ResourceManager.getInstance().getString('BuilderStrings', 'unknownErrorMessage',
                                                                            [ event.error.toString(), logFile.nativePath ]);
        const errorPopUp:UnknownErrorPopUp = new UnknownErrorPopUp();
        errorPopUp.errorContent = errorContent;
        errorPopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    private function setStatusAndAlert(text:String):void
    {
        Model.instance.status = text;
        BuilderAlert.show(text, ResourceManager.getInstance().getString('BuilderStrings', 'error'));
    }

    protected function widgetTypeLoader_completeHandler(event:Event):void
    {
        (event.currentTarget as WidgetTypeLoader).removeEventListener(Event.COMPLETE, widgetTypeLoader_completeHandler);
        validateSettings();
    }

    private function validateSettings():void
    {
        AppEvent.dispatch(AppEvent.SAVE_SETTINGS, Model.instance.exportSettings());
    }
}
}
