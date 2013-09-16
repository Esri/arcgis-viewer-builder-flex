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

import com.esri.builder.controllers.supportClasses.LocalConnectionDelegate;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.AssetImporter;
import com.esri.builder.supportClasses.LogUtil;

import flash.filesystem.File;

import mx.logging.ILogger;

public final class LogoController
{
    private const LOG:ILogger = LogUtil.createLogger(LogoController);

    public var localConnectionDelegate:LocalConnectionDelegate;

    public function LogoController()
    {
        AppEvent.addListener(AppEvent.LOGO_EXECUTE, onLogoExecute, false, 0, true);
    }

    private function onLogoExecute(event:AppEvent):void
    {
        logoExecute(event.data as File);
    }

    private function logoExecute(newLogo:File):void
    {
        const newLogo:File = AssetImporter.importImage(newLogo);
        const logo:String = 'assets/images/' + newLogo.name;
        LOG.debug('logo relative URL {0}', logo);

        Model.instance.config.logo = logo;
        localConnectionDelegate.setLogo(logo);
    }
}
}
