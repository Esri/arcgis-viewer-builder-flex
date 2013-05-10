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
import com.esri.builder.views.BuilderAlert;

import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.resources.ResourceManager;

public final class LayersController
{

    public function LayersController()
    {
        AppEvent.addListener(AppEvent.LOAD_LAYERS, onLoadLayers, false, 0, true);
    }

    private function onLoadLayers(event:AppEvent):void
    {
        if (Model.instance.config.configMap.itemId)
        {
            BuilderAlert.show(
                ResourceManager.getInstance().getString('BuilderStrings', 'viewer.webmapExistsText'),
                ResourceManager.getInstance().getString('BuilderStrings', 'viewer.webmapExistsTitle'),
                Alert.YES | Alert.NO, null, alertHandler);
            function alertHandler(event:CloseEvent):void
            {
                if (event.detail === Alert.YES)
                {
                    Model.instance.config.configMap.itemId = '';
                    Model.instance.configBasemapsList.removeAllLayers();
                    Model.instance.configOpsLayerList.removeAllLayers();
//                    Model.instance.appState = 'layers';
                }
            }
        }
        else
        {
//            Model.instance.appState = 'layers';
        }
    }
}
}
