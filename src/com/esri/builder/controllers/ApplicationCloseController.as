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
import com.esri.builder.supportClasses.ApplicationCloseWarningEvent;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.popups.CloseApplicationConfirmPopUp;

import flash.events.Event;
import flash.filesystem.File;

import mx.core.FlexGlobals;
import mx.logging.ILogger;
import mx.managers.PopUpManager;

import spark.components.WindowedApplication;

public final class ApplicationCloseController
{
    private static const LOG:ILogger = LogUtil.createLogger(ApplicationCloseController);

    private var closeApplicationConfirmPopUp:CloseApplicationConfirmPopUp;

    private var application:WindowedApplication;

    public function ApplicationCloseController()
    {
        application = FlexGlobals.topLevelApplication as WindowedApplication;
        application.addEventListener(Event.CLOSING, nativeWindow_closingHandler);
    }

    private function nativeWindow_closingHandler(event:Event):void
    {
        LOG.info("App is closing");

        if (Model.instance.config.isDirty)
        {
            LOG.debug("Preventing application close");

            event.preventDefault();
            if (closeApplicationConfirmPopUp)
            {
                return;
            }
            showCloseWarningPopUp();
        }
        else
        {
            deleteTempFolder();
        }
    }

    private function showCloseWarningPopUp():void
    {
        closeApplicationConfirmPopUp = new CloseApplicationConfirmPopUp();
        closeApplicationConfirmPopUp.addEventListener(ApplicationCloseWarningEvent.CANCEL, closeApplicationConfirmPopUp_cancelHandler, false, 0, true);
        closeApplicationConfirmPopUp.addEventListener(ApplicationCloseWarningEvent.SAVE_AND_CLOSE, closeApplicationConfirmPopUp_saveAndCloseHandler, false, 0, true);
        closeApplicationConfirmPopUp.addEventListener(ApplicationCloseWarningEvent.DISCARD_AND_CLOSE, closeApplicationConfirmPopUp_discardAndCloseHandler, false, 0, true);
        PopUpManager.addPopUp(closeApplicationConfirmPopUp, application, true);
        PopUpManager.centerPopUp(closeApplicationConfirmPopUp);
    }

    private function closeApplicationConfirmPopUp_cancelHandler(event:ApplicationCloseWarningEvent):void
    {
        cleanUpCloseApplicationPopUp(event);
    }

    private function closeApplicationConfirmPopUp_saveAndCloseHandler(event:ApplicationCloseWarningEvent):void
    {
        cleanUpCloseApplicationPopUp(event);

        AppEvent.addListener(AppEvent.CONFIG_XML_SAVED, configXMLSaved);
        AppEvent.dispatch(AppEvent.SAVE_CONFIG_XML, 'webmap');
    }

    private function configXMLSaved(event:AppEvent):void
    {
        AppEvent.removeListener(AppEvent.CONFIG_XML_SAVED, configXMLSaved);
        closeApplication();
    }

    private function closeApplication():void
    {
        LOG.info("Exiting application.");

        application.exit();
    }

    private function closeApplicationConfirmPopUp_discardAndCloseHandler(event:ApplicationCloseWarningEvent):void
    {
        cleanUpCloseApplicationPopUp(event);
        closeApplication();
    }

    private function cleanUpCloseApplicationPopUp(event:ApplicationCloseWarningEvent):void
    {
        closeApplicationConfirmPopUp.removeEventListener(ApplicationCloseWarningEvent.CANCEL, closeApplicationConfirmPopUp_cancelHandler);
        closeApplicationConfirmPopUp.removeEventListener(ApplicationCloseWarningEvent.SAVE_AND_CLOSE, closeApplicationConfirmPopUp_saveAndCloseHandler);
        closeApplicationConfirmPopUp.removeEventListener(ApplicationCloseWarningEvent.DISCARD_AND_CLOSE, closeApplicationConfirmPopUp_discardAndCloseHandler);

        PopUpManager.removePopUp(closeApplicationConfirmPopUp);
        closeApplicationConfirmPopUp = null;
    }

    private function deleteTempFolder():void
    {
        if (Model.instance.baseDir)
        {
            const tempFile:File = Model.instance.baseDir.resolvePath(Model.TEMP_DIR_NAME);
            if (tempFile.exists)
            {
                tempFile.moveToTrash();
            }
        }
    }
}
}
