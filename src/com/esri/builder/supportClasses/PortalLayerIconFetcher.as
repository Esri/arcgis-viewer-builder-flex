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
package com.esri.builder.supportClasses
{

import com.esri.builder.model.Model;
import com.esri.builder.model.PortalLayer;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import mx.logging.ILogger;

public class PortalLayerIconFetcher extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(PortalLayerIconFetcher);

    public function fetchIconURL(portalLayer:PortalLayer):void
    {
        LOG.info("fetching portal item icon");

        var iconURL:String = portalLayer.thumbnailURL;
        if (!iconURL)
        {
            LOG.warn("No thumbnail URL available");
            dispatchCompletionEvent();
        }
        else if (portalLayer.isPublic)
        {
            var tokenIndex:int = iconURL.indexOf("?");
            var hasToken:Boolean = (tokenIndex > -1);
            iconURL = hasToken ? iconURL.substr(0, tokenIndex) : iconURL;
            LOG.debug("Public item icon: {0}", iconURL);
            dispatchCompletionEvent(iconURL);
        }
        else
        {
            LOG.debug("Private item icon. Need to save locally.");
            saveIconFile(iconURL);
        }
    }

    private function dispatchCompletionEvent(iconPath:String = ""):void
    {
        dispatchEvent(new IconFetchEvent(IconFetchEvent.FETCH_COMPLETE, iconPath));
    }

    private function saveIconFile(url:String):void
    {
        LOG.debug("Fetching icon");

        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;

        loader.addEventListener(Event.COMPLETE, loader_completeHandler);
        loader.addEventListener(IOErrorEvent.IO_ERROR, loader_errorHandler);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_errorHandler);

        loader.load(new URLRequest(url));

        function loader_completeHandler(event:Event):void
        {
            LOG.debug("Icon fetch complete");
            removeLoaderListeners();

            var iconFilePath:String = createIconFilePath(url);
            saveDataTo(loader.data, getAppRelativeDestination(iconFilePath));

            dispatchCompletionEvent(iconFilePath);
        }

        function removeLoaderListeners():void
        {
            loader.removeEventListener(Event.COMPLETE, loader_completeHandler);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, loader_errorHandler);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_errorHandler);
        }

        function loader_errorHandler(event:Event):void
        {
            LOG.warn("Could not load icon data - error: {0}", event.type);
            removeLoaderListeners();
            dispatchCompletionEvent();
        }
    }

    private function createIconFilePath(url:String):String
    {
        var iconFilename:String = extractIconFilename(url);
        return FileUtil.generateUniqueRelativePath(Model.instance.appDir,
                                                   "assets/images/" + iconFilename);
    }

    private function extractIconFilename(url:String):String
    {
        var iconFilenamePattern:RegExp = /[^\/]?\w+\.(jpeg|jpg|png|gif)/i;

        var iconFilenameIndex:int = url.search(iconFilenamePattern);
        var iconFilename:String = url.substring(iconFilenameIndex);
        var tokenIndex:int = iconFilename.indexOf("?");
        if (tokenIndex > -1)
        {
            iconFilename = iconFilename.substr(0, tokenIndex);
        }

        return iconFilename;
    }

    private function getAppRelativeDestination(iconFilePath:String):File
    {
        return Model.instance.appDir.resolvePath(iconFilePath);
    }

    private function saveDataTo(iconBytes:ByteArray, iconFile:File):void
    {
        var fileWriter:FileStream = new FileStream();
        try
        {
            fileWriter.open(iconFile, FileMode.WRITE);
            fileWriter.writeBytes(iconBytes);
            fileWriter.close();
            LOG.debug("Saved icon at: {0}", iconFile.nativePath);
        }
        catch (error:Error)
        {
            LOG.warn("Could not save icon at: {0}, details: {1}", iconFile.nativePath, error.toString());
        }
    }
}
}
