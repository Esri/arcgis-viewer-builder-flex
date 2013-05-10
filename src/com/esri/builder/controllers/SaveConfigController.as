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
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;

public final class SaveConfigController
{
    private static const LOG:ILogger = LogUtil.createLogger(SaveConfigController);

    public var htmlWrapperUpdater:HTMLWrapperUpdater;

    public function SaveConfigController()
    {
        AppEvent.addListener(AppEvent.SAVE_CONFIG_XML, onSaveConfigXml, false, 0, true);
    }

    private function onSaveConfigXml(event:AppEvent):void
    {
        var appConfigXML:XML = Model.instance.config.toConfigXML();
        if (writeConfigXML(Model.instance.appDir, appConfigXML))
        {
            Model.instance.config.isDirty = false;
            htmlWrapperUpdater.updateHTMLWrapper(Model.instance.appDir, appConfigXML);
            AppEvent.dispatch(AppEvent.CONFIG_XML_SAVED, event.data);
        }
    }

    private function writeConfigXML(projectDir:File, configXML:XML):Boolean
    {
        if (Log.isInfo())
        {
            LOG.info("Writing config XML for {0}", projectDir.nativePath);
        }

        var success:Boolean = false;
        const configText:String = "<?xml version=\"1.0\" ?>\n" + configXML.toXMLString() + "\n";
        const configFile:File = projectDir.resolvePath("config.xml");
        if (Log.isInfo())
        {
            LOG.info('Saving configuration to {0}', configFile.nativePath);
        }
        if (Log.isDebug())
        {
            LOG.debug(configText);
        }

        const fileStream:FileStream = new FileStream();
        try
        {
            fileStream.open(configFile, FileMode.WRITE);
            try
            {
                if (Log.isDebug())
                {
                    LOG.debug("Config XML write success");
                }

                fileStream.writeUTFBytes(configText);
                success = true;
            }
            finally
            {
                fileStream.close();
            }
        }
        catch (e:Error)
        {
            if (Log.isError())
            {
                LOG.error('Problem writing config: {0}', e.message);
            }
            BuilderAlert.show(e.message.toString(), ResourceManager.getInstance().getString('BuilderStrings', 'error'));
        }
        return success;
    }
}
}
