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

import com.esri.builder.controllers.supportClasses.processes.CleanUpProcess;
import com.esri.builder.controllers.supportClasses.processes.ProcessArbiter;
import com.esri.builder.controllers.supportClasses.processes.ProcessArbiterEvent;
import com.esri.builder.controllers.supportClasses.WellKnownDirectories;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.WidgetType;
import com.esri.builder.model.WidgetTypeRegistryModel;
import com.esri.builder.views.BuilderAlert;

import flash.filesystem.File;

import mx.resources.ResourceManager;

public class RemoveCustomWidgetController
{
    private var removeWidgetArbiter:ProcessArbiter;

    private var widgetTypeToRemove:WidgetType;

    public function RemoveCustomWidgetController()
    {
        AppEvent.addListener(AppEvent.REMOVE_CUSTOM_WIDGET, removeCustomWidgetHandler);
    }

    private function removeCustomWidgetHandler(importCustomWidget:AppEvent):void
    {
        widgetTypeToRemove = importCustomWidget.data as WidgetType;
        removeWidget(widgetTypeToRemove);
    }

    private function removeWidget(widgetType:WidgetType):void
    {
        removeWidgetArbiter = new ProcessArbiter();
        removeWidgetArbiter.addEventListener(ProcessArbiterEvent.COMPLETE, importArbiter_completeHandler);
        removeWidgetArbiter.addEventListener(ProcessArbiterEvent.FAILURE, importArbiter_failureHandler);

        var customWidgetModule:File = WellKnownDirectories.getInstance().customModules.resolvePath(widgetTypeToRemove.name + "Module.swf");
        var customWidgetConfig:File = WellKnownDirectories.getInstance().customModules.resolvePath(widgetTypeToRemove.name + "Module.xml");
        var customWidgetFolder:File = WellKnownDirectories.getInstance().customFlexViewer.resolvePath("widgets/" + widgetType.name);

        removeWidgetArbiter.addProcess(new CleanUpProcess(customWidgetModule));
        removeWidgetArbiter.addProcess(new CleanUpProcess(customWidgetConfig));
        removeWidgetArbiter.addProcess(new CleanUpProcess(customWidgetFolder));

        removeWidgetArbiter.executeProcs();
    }

    protected function importArbiter_completeHandler(event:ProcessArbiterEvent):void
    {
        removeWidgetArbiter.removeEventListener(ProcessArbiterEvent.COMPLETE, importArbiter_completeHandler);
        removeWidgetArbiter.removeEventListener(ProcessArbiterEvent.FAILURE, importArbiter_failureHandler);

        WidgetTypeRegistryModel.getInstance().widgetTypeRegistry.removeWidgetType(widgetTypeToRemove);
        AppEvent.dispatch(AppEvent.REMOVE_CUSTOM_WIDGET_SUCCESS);
    }

    protected function importArbiter_failureHandler(event:ProcessArbiterEvent):void
    {
        removeWidgetArbiter.removeEventListener(ProcessArbiterEvent.COMPLETE, importArbiter_completeHandler);
        removeWidgetArbiter.removeEventListener(ProcessArbiterEvent.FAILURE, importArbiter_failureHandler);

        var removeCustomWidgetFailureMessage:String = ResourceManager.getInstance().getString("BuilderStrings",
                                                                                              "removeCustomWidgetProcess.failure",
                                                                                              [ event.message ]);
        var removeCustomWidgetFailureTitle:String = ResourceManager.getInstance().getString("BuilderStrings",
                                                                                            "widgetManager.removeCustomWidget");
        BuilderAlert.show(removeCustomWidgetFailureMessage, removeCustomWidgetFailureTitle);

        AppEvent.dispatch(AppEvent.REMOVE_CUSTOM_WIDGET_FAILURE);
    }
}
}
