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

import flash.system.Capabilities;

import mx.managers.ToolTipManager;

import spark.components.WindowedApplication;
import spark.effects.Fade;

public final class CreationCompleteController
{
    private var m_showEffect:Fade = new Fade();
    private var m_hideEffect:Fade = new Fade();

    public function CreationCompleteController()
    {
        AppEvent.addListener(AppEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true);
    }

    private function creationCompleteHandler(event:AppEvent):void
    {
        creationComplete(event.data as WindowedApplication);
    }

    private function creationComplete(app:WindowedApplication):void
    {
        // Center the app on the screen here to avoid flicker.
        app.nativeWindow.x = (Capabilities.screenResolutionX - app.nativeWindow.width) * 0.5;
        app.nativeWindow.y = (Capabilities.screenResolutionY - app.nativeWindow.height) * 0.5;

        m_showEffect.alphaFrom = 0;
        m_showEffect.alphaTo = 1;
        m_showEffect.duration = 300;

        m_hideEffect.alphaFrom = 1;
        m_hideEffect.alphaTo = 0;
        m_hideEffect.duration = 300;

        // Set Tooltip properties - http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf60d65-7ffe.html
        ToolTipManager.showDelay = 200;
        // ToolTipManager.hideDelay = 1200;
        ToolTipManager.showEffect = m_showEffect;
        ToolTipManager.hideEffect = m_hideEffect;
    }
}
}
