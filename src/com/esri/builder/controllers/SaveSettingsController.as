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

import com.esri.builder.controllers.supportClasses.Settings;
import com.esri.builder.controllers.supportClasses.SettingsValidationEvent;
import com.esri.builder.controllers.supportClasses.SettingsValidator;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.LogUtil;
import com.esri.builder.views.BuilderAlert;

import flash.net.SharedObject;

import mx.logging.ILogger;
import mx.resources.ResourceManager;

public final class SaveSettingsController
{
    private static const LOG:ILogger = LogUtil.createLogger(SaveSettingsController);

    public var settingsValidator:SettingsValidator;

    public function SaveSettingsController()
    {
        AppEvent.addListener(AppEvent.SAVE_SETTINGS, onSaveSettings, false, 0, true);
    }

    private function onSaveSettings(event:AppEvent):void
    {
        Model.instance.status = ResourceManager.getInstance().getString('BuilderStrings', 'saveSettings.savingSettings');

        settingsValidator.addEventListener(SettingsValidationEvent.VALID_SETTINGS, settingsValidator_validSettingsHandler);
        settingsValidator.addEventListener(SettingsValidationEvent.INVALID_SETTINGS, settingsValidator_invalidSettingsHandler);
        settingsValidator.validateSettings(event.data as Settings);
    }

    private function settingsValidator_validSettingsHandler(event:SettingsValidationEvent):void
    {
        settingsValidator.removeEventListener(SettingsValidationEvent.INVALID_SETTINGS, settingsValidator_invalidSettingsHandler);
        settingsValidator.removeEventListener(SettingsValidationEvent.VALID_SETTINGS, settingsValidator_validSettingsHandler);

        saveUserPref(event.settings);

        Model.instance.importSettings(event.settings);
        Model.instance.status = '';
        Model.instance.appState = 'home';

        Model.instance.config.isDirty = false;
        AppEvent.dispatch(AppEvent.SETTINGS_SAVED);
    }

    private function settingsValidator_invalidSettingsHandler(event:SettingsValidationEvent):void
    {
        settingsValidator.removeEventListener(SettingsValidationEvent.INVALID_SETTINGS, settingsValidator_invalidSettingsHandler);
        settingsValidator.removeEventListener(SettingsValidationEvent.VALID_SETTINGS, settingsValidator_validSettingsHandler);

        BuilderAlert.show(event.message, ResourceManager.getInstance().getString("BuilderStrings", "settings.invalidSettings"));
        Model.instance.status = event.message;
        Model.instance.appState = 'settings';
    }

    private function saveUserPref(settings:Settings):void
    {
        LOG.info("Saving settings");

        const so:SharedObject = SharedObject.getLocal(Model.USER_PREF);
        so.data.baseURL = settings.webServerURL;
        so.data.baseLoc = settings.webServerFolder;
        so.data.locale = settings.locale;
        so.data.bingKey = settings.bingKey;
        so.data.httpProxy = settings.proxyURL;
        so.data.userGeometryServiceURL = settings.geometryServiceURL;
        so.data.geocodeURL = settings.geocodeURL;
        so.data.directionsURL = settings.directionsURL;
        so.data.printTaskURL = settings.printTaskURL;
        so.data.userPortalURL = settings.portalURL
        so.data.isTutorialModeEnabled = settings.isTutorialModeEnabled;
        so.close();
    }
}
}
