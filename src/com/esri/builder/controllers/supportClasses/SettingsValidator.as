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
import com.esri.builder.supportClasses.LogUtil;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.getTimer;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import mx.utils.StringUtil;

public final class SettingsValidator extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(SettingsValidator);

    private var settings:Settings;
    private var tempFile:File;
    private var baseDirectory:File;

    public function validateSettings(settings:Settings):void
    {
        this.settings = settings;

        const emptyRE:RegExp = /^\s*$/;
        if (!settings.webServerURL || emptyRE.test(settings.webServerURL))
        {
            if (Log.isDebug())
            {
                LOG.debug('No web server URL');
            }

            dispatchValidationFailure(getLocalizedMessage('settings.baseURLRequired'));
            return;
        }
        if (!settings.webServerFolder || emptyRE.test(settings.webServerFolder))
        {
            if (Log.isDebug())
            {
                LOG.debug('No web server folder');
            }

            dispatchValidationFailure(getLocalizedMessage('settings.baseLocRequired'));
            return;
        }
        if (/^\\\\.+$/.test(settings.webServerFolder))
        {
            if (Log.isDebug())
            {
                LOG.debug('Web server folder does not start with drive name');
            }

            dispatchValidationFailure(getLocalizedMessage('settings.baseLocShared'));
            return;
        }
        if (settings.proxyURL)
        {
            const urlRE:RegExp = /https?:\/\/([^\s.]+.)+([^\s.]+)/; // TODO - make more robust
            if (!urlRE.test(settings.proxyURL))
            {
                if (Log.isDebug())
                {
                    LOG.debug('Invalid HTTP proxy');
                }

                dispatchValidationFailure(getLocalizedMessage('settings.httpProxyInvalid'));
                return;
            }
        }

        if (settings.geometryServiceURL)
        {
            if (!/^https?:\/\/.+\/GeometryServer$/.test(settings.geometryServiceURL))
            {
                if (Log.isDebug())
                {
                    LOG.debug('Invalid geometry service URL');
                }

                dispatchValidationFailure(getLocalizedMessage('settings.geometryServiceInvalidURL'));
                return;
            }
        }

        if (settings.portalURL)
        {
            const urlRE_portalURL:RegExp = /https?:\/\/([^\s.]+.)+([^\s.]+)/; // TODO - make more robust
            if (!urlRE_portalURL.test(settings.portalURL))
            {
                if (Log.isDebug())
                {
                    LOG.debug('Invalid Portal for ArcGIS URL');
                }

                dispatchValidationFailure(getLocalizedMessage('settings.portalForArcGISURLInvalid'));
                return;
            }
        }

        try
        {
            baseDirectory = new File(settings.webServerFolder);
        }
        catch (error:Error)
        {
            if (Log.isDebug())
            {
                LOG.debug('Invalid base directory path {0}', settings.webServerFolder);
            }

            dispatchValidationFailure(getLocalizedMessage('saveSettings.invalidBaseDir', settings.webServerFolder));
            return;
        }

        var doesBaseDirectoryPointToExistingFile:Boolean = (baseDirectory.exists && !baseDirectory.isDirectory);
        if (doesBaseDirectoryPointToExistingFile)
        {
            if (Log.isDebug())
            {
                LOG.debug('Base directory is not a directory {0}', settings.webServerFolder);
            }

            dispatchValidationFailure(getLocalizedMessage('saveSettings.builderIsNotDir', settings.webServerFolder));
            return;
        }

        if (!canCreateBaseDirectory())
        {
            if (Log.isDebug())
            {
                LOG.debug('Could not create {0}', settings.webServerFolder);
            }

            dispatchValidationFailure(getLocalizedMessage('saveSettings.cannotCreate', settings.webServerFolder));
            return;
        }

        tempFile = createTempFile();

        if (!canWriteToViewerDir(tempFile))
        {
            deleteFile(tempFile);
            dispatchValidationFailure(getLocalizedMessage('saveSettings.cannotWrite', settings.webServerFolder));
            return;
        }

        if (!canReadFromViewerDir(tempFile))
        {
            deleteFile(tempFile);
            dispatchValidationFailure(getLocalizedMessage('saveSettings.cannotRead', settings.webServerFolder));
            return;
        }

        loadTempFileFromBaseURL();
    }

    private function dispatchValidationFailure(errorMessage:String = null):void
    {
        if (Log.isInfo())
        {
            LOG.info("Settings are not valid: {0}", errorMessage);
        }

        dispatchEvent(new SettingsValidationEvent(SettingsValidationEvent.INVALID_SETTINGS, settings, errorMessage));
    }

    private function getLocalizedMessage(key:String, ... params):String
    {
        return StringUtil.substitute(
            ResourceManager.getInstance().getString('BuilderStrings', key),
            params);
    }

    private function canCreateBaseDirectory():Boolean
    {
        var couldCreateBaseDirectory:Boolean;
        try
        {
            baseDirectory.createDirectory();
            couldCreateBaseDirectory = true;
        }
        catch (error:Error)
        {
            couldCreateBaseDirectory = false;
        }

        return couldCreateBaseDirectory;
    }

    private function createTempFile():File
    {
        return baseDirectory.resolvePath(Model.TEMP_DIR_NAME + getTimer() + ".html");
    }

    private function canWriteToViewerDir(tempFile:File):Boolean
    {
        var canWrite:Boolean;
        if (Log.isDebug())
        {
            LOG.debug('Checking if can write {0}', tempFile.nativePath);
        }
        try
        {
            const fileStream:FileStream = new FileStream();
            fileStream.open(tempFile, FileMode.WRITE);
            fileStream.writeInt(1234);
            fileStream.close();
            canWrite = true;
        }
        catch (e:Error)
        {
            canWrite = false;
        }
        return canWrite;
    }

    private function deleteFile(tempFile:File):void
    {
        try
        {
            tempFile.deleteFile();
        }
        catch (error:Error)
        {
            //handle silently
        }
    }

    private function canReadFromViewerDir(tempFile:File):Boolean
    {
        var canRead:Boolean;
        if (Log.isDebug())
        {
            LOG.debug('Checking if can read {0}', tempFile.nativePath);
        }
        try
        {
            const fileStream:FileStream = new FileStream();
            fileStream.open(tempFile, FileMode.READ);
            fileStream.readInt();
            fileStream.close();
            canRead = true;
        }
        catch (e:Error)
        {
            canRead = false;
        }
        return canRead;
    }

    private function loadTempFileFromBaseURL():void
    {
        const httpService:HTTPService = new HTTPService();
        httpService.useProxy = false;
        httpService.requestTimeout = Model.REQUEST_TIMEOUT;
        httpService.url = settings.webServerURL + '/' + tempFile.name;
        httpService.addEventListener(ResultEvent.RESULT, httpService_resultHandler);
        httpService.addEventListener(FaultEvent.FAULT, httpService_faultHandler);
        httpService.send();
    }

    private function httpService_resultHandler(event:ResultEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info('Valid {0}', settings.webServerURL);
        }

        (event.currentTarget as IEventDispatcher).removeEventListener(ResultEvent.RESULT, httpService_resultHandler);
        (event.currentTarget as IEventDispatcher).removeEventListener(FaultEvent.FAULT, httpService_faultHandler);

        deleteFile(tempFile);
        dispatchValidationSuccess();
    }

    private function dispatchValidationSuccess():void
    {
        if (Log.isInfo())
        {
            LOG.info("Settings are valid");
        }

        dispatchEvent(new SettingsValidationEvent(SettingsValidationEvent.VALID_SETTINGS, settings));
    }

    private function httpService_faultHandler(event:FaultEvent):void
    {
        if (Log.isInfo())
        {
            LOG.info('Problem with Web Server Base Folder URL: {0}', event.fault.toString());
        }

        (event.currentTarget as IEventDispatcher).removeEventListener(ResultEvent.RESULT, httpService_resultHandler);
        (event.currentTarget as IEventDispatcher).removeEventListener(FaultEvent.FAULT, httpService_faultHandler);

        deleteFile(tempFile);
        dispatchValidationFailure(getLocalizedMessage('saveSettings.checkWebServerBaseFolderURL'));
    }
}
}
