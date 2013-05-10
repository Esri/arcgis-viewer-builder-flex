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

import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;
import com.esri.builder.views.popups.SaveChangesPopUp;

import flash.display.DisplayObjectContainer;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.resources.ResourceManager;

import spark.events.PopUpEvent;

public final class SaveChangesController
{
    private static const LOG:ILogger = LogUtil.createLogger(SaveChangesController);

    public var loadWidgetConfigurations:LoadWidgetConfigurations = new LoadWidgetConfigurations;

    private var _saveConfigAndChangeView:Boolean;
    private var _saveChangesOrigin:String;

    public function SaveChangesController()
    {
        AppEvent.addListener(AppEvent.CONFIG_XML_SAVED, onConfigXMLSave, false, 0, true);
        AppEvent.addListener(AppEvent.SAVE_CHANGES, onSaveChanges, false, 0, true);
    }

    private function onSaveChanges(event:AppEvent):void
    {
        _saveChangesOrigin = String(event.data);

        if (Log.isInfo())
        {
            LOG.info("Unsaved changes");
        }

        if (Log.isDebug())
        {
            LOG.debug("Unsaved changes origin {0}", _saveChangesOrigin);
        }

        var saveChangesPopUp:SaveChangesPopUp = new SaveChangesPopUp();
        saveChangesPopUp.addEventListener(PopUpEvent.CLOSE, saveChangesPopUp_closeHandler, false, 0, true);
        saveChangesPopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    private function saveChangesPopUp_closeHandler(event:PopUpEvent):void
    {
        var saveChangesPopUp:SaveChangesPopUp = event.currentTarget as SaveChangesPopUp;
        saveChangesPopUp.removeEventListener(PopUpEvent.CLOSE, saveChangesPopUp_closeHandler);

        if (event.commit)
        {
            if (Log.isInfo())
            {
                LOG.info("Saving changes");
            }
            _saveConfigAndChangeView = true;
            AppEvent.dispatch(AppEvent.SAVE_CONFIG_XML);
        }
        else
        {
            if (Log.isInfo())
            {
                LOG.info("Reverting unsaved changes");
            }

            // revert the changes
            if (!Model.instance.config.readConfigXML())
            {
                if (Log.isError())
                {
                    LOG.error("Could not read config XML");
                }

                const text:String = ResourceManager.getInstance().getString('BuilderStrings', 'createApp.noConfigXMLText');
                const title:String = ResourceManager.getInstance().getString('BuilderStrings', 'createApp.noConfigXMLTitle');
                Model.instance.status = text;
                BuilderAlert.show(text, title);
            }
            else
            {
                if (Log.isInfo())
                {
                    LOG.info("Reverted changes");
                }

                loadWidgetConfigurations.loadWidgetConfigurations();
                Model.instance.config.isDirty = false;
                AppEvent.dispatch(AppEvent.CHANGES_SAVED, _saveChangesOrigin);
            }
        }
    }

    private function onConfigXMLSave(event:AppEvent):void
    {
        if (_saveConfigAndChangeView)
        {
            _saveConfigAndChangeView = false;
            AppEvent.dispatch(AppEvent.CHANGES_SAVED, _saveChangesOrigin);
        }
    }
}
}
