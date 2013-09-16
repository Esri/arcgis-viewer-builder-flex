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

import com.esri.builder.model.ConfigLayer;
import com.esri.builder.model.Model;
import com.esri.builder.model.PortalLayer;

import flash.display.LoaderInfo;
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

public class ConfigLayerIconHandler extends EventDispatcher
{
    private static const LOG:ILogger = LogUtil.createLogger(ConfigLayerIconHandler);

    private var configLayer:ConfigLayer;
    private var thumbnailURL:String;

    public function assignIconURL(basemap:PortalLayer, configLayer:ConfigLayer):void
    {
        LOG.info("Assigning config layer icon");

        if (!basemap.thumbnailURL)
        {
            LOG.warn("No thumbnail URL available");

            dispatchEvent(new Event(Event.COMPLETE));
            return;
        }

        if (basemap.isPublic)
        {
            var tokenIndex:int = basemap.thumbnailURL.indexOf("?");
            var hasToken:Boolean = (tokenIndex > -1);
            configLayer.icon = hasToken ? basemap.thumbnailURL.substr(0, tokenIndex) : basemap.thumbnailURL;

            LOG.debug("Public basemap icon: {0}", configLayer.icon);

            dispatchEvent(new Event(Event.COMPLETE));
        }
        else
        {
            LOG.debug("Private basemap icon. Need to save locally.");

            this.configLayer = configLayer;
            this.thumbnailURL = basemap.thumbnailURL;
            saveThumbnailImage();
        }
    }

    private function saveThumbnailImage():void
    {
        LOG.debug("Fetching icon");

        var loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, loader_completeHandler);
        loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
        loader.load(new URLRequest(thumbnailURL));
    }

    protected function loader_completeHandler(event:Event):void
    {
        LOG.debug("Icon fetch complete");

        var urlLoader:URLLoader = event.currentTarget as URLLoader;
        urlLoader.removeEventListener(Event.COMPLETE, loader_completeHandler);
        urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
        urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);

        var iconFilename:String = extractImageFilenameFromThumbnailURL();
        saveIconFileToAppAssets(urlLoader.data, iconFilename);

        LOG.debug("Icon filename: {0}", iconFilename);

        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function extractImageFilenameFromThumbnailURL():String
    {
        var imageFilename:RegExp = /[^\/]?\w+\.(jpeg|jpg|png|gif)/i;
        var imageFilenameIndex:int = thumbnailURL.search(imageFilename);
        var iconFilename:String = thumbnailURL.substring(imageFilenameIndex)
        var tokenIndex:int = iconFilename.indexOf("?");
        if (tokenIndex > -1)
        {
            iconFilename = iconFilename.substr(0, tokenIndex);
        }

        return iconFilename;
    }

    private function saveIconFileToAppAssets(iconBytes:ByteArray, iconFilename:String):void
    {
        LOG.debug("Saving icon locally.");

        var iconFilePath:String = FileUtil.generateUniqueRelativePath(Model.instance.appDir,
                                                                      "assets/images/" + iconFilename);
        var iconFile:File = Model.instance.appDir.resolvePath(iconFilePath);
        var fileWriter:FileStream = new FileStream();
        try
        {
            fileWriter.open(iconFile, FileMode.WRITE);
            fileWriter.writeBytes(iconBytes);
            fileWriter.close();
            configLayer.icon = iconFilePath;

            LOG.debug("Saved icon at: {0}", iconFilePath);
        }
        catch (error:Error)
        {
            LOG.warn("Could not save icon at: {0}, details: {1}", iconFilePath, error.toString());
                //Fail silently
        }
    }

    protected function loader_ioErrorHandler(event:Event):void
    {
        LOG.warn("Could not load icon data - IO error");

        var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
        loaderInfo.removeEventListener(Event.COMPLETE, loader_completeHandler);
        loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
        loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
        //Fail silently

        dispatchEvent(new Event(Event.COMPLETE));
    }

    protected function loader_securityErrorHandler(event:Event):void
    {
        LOG.warn("Could not load icon data - security error");

        var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
        loaderInfo.removeEventListener(Event.COMPLETE, loader_completeHandler);
        loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
        loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
        //Fail silently

        dispatchEvent(new Event(Event.COMPLETE));
    }
}
}
