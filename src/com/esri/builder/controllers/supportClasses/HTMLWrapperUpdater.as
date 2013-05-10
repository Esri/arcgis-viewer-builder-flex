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
import com.esri.builder.views.BuilderAlert;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;

public final class HTMLWrapperUpdater
{
    public static const INDEX_HTML_FILENAME:String = "index.html";
    public static const DEFAULT_HTM_FILENAME:String = "default.htm";

    public const LOG:ILogger = Log.getLogger('com.esri.builder.controllers.supportClasses.HTMLWrapperUpdater');

    public function updateHTMLWrapper(projectDir:File, appConfigXML:XML = null):void
    {
        const indexHTML:File = projectDir.resolvePath(INDEX_HTML_FILENAME);

        if (Log.isInfo())
        {
            LOG.info('Updating {0}', indexHTML.nativePath);
        }

        var oldContent:String;
        try
        {
            oldContent = getTextFileContents(indexHTML);
        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Error reading index.html: {0}', e.getStackTrace());
            }
            BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'htmlWrapperUpdater.cannotRead', [ INDEX_HTML_FILENAME ]),
                              ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }

        var newContent:String = updateFlashVars(oldContent);
        if (appConfigXML)
        {
            const appTitle:String = appConfigXML.title;
            newContent = updateTitleTag(appTitle, newContent);
        }

        try
        {
            updateTextFileContents(indexHTML, newContent);
        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Error while updating index.html: {0}', e.getStackTrace());
            }
            BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'htmlWrapperUpdater.cannotUpdate', [ INDEX_HTML_FILENAME ]),
                              ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }

        const defaultHTM:File = projectDir.resolvePath(DEFAULT_HTM_FILENAME);
        try
        {
            updateTextFileContents(defaultHTM, newContent);
        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Error while updating default.htm: {0}', e.getStackTrace());
            }
            BuilderAlert.show(ResourceManager.getInstance().getString('BuilderStrings', 'htmlWrapperUpdater.cannotUpdate', [ DEFAULT_HTM_FILENAME ]),
                              ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
    }

    private function getTextFileContents(textFile:File):String
    {
        var fileContents:String;
        var fileStream:FileStream = new FileStream();
        fileStream.open(textFile, FileMode.READ);
        fileContents = fileStream.readUTFBytes(fileStream.bytesAvailable);
        fileStream.close();
        fileStream = null;
        return fileContents;
    }

    private function updateTextFileContents(textFile:File, content:String):void
    {
        var fileStream:FileStream = new FileStream();
        fileStream.open(textFile, FileMode.WRITE);
        fileStream.writeUTFBytes(content);
        fileStream.close();
        fileStream = null;
    }

    private function updateTitleTag(title:String, content:String):String
    {
        const titleTag:String = "<title>" + title + "</title>";
        return content.replace(/<title[\s]*>[\w\W]*<\/title[\s]*>/g, titleTag);
    }

    private function updateFlashVars(content:String):String
    {
        const appLocale:String = Model.instance.locale;
        return updateResourceModuleURL(appLocale,
                                       updateLocaleChain(appLocale, content));
    }

    private function updateResourceModuleURL(appLocale:String, content:String):String
    {
        //TODO: need to handle missing 'flashvars.resourceModuleURLs'
        const resourceModuleURL:String = "assets/locale/" + appLocale + ".swf";
        const resourceModuleURLContent:String = 'flashvars.resourceModuleURLs = "' + resourceModuleURL + '";';
        return content.replace(/flashvars\.resourceModuleURLs[^;]+;/, resourceModuleURLContent);
    }

    private function updateLocaleChain(appLocale:String, content:String):String
    {
        //TODO: need to handle missing 'flashvars.localeChain'
        const localeChainContent:String = 'flashvars.localeChain = "' + appLocale + '";';
        return content.replace(/flashvars\.localeChain[^;]+;/, localeChainContent);
    }
}
}
