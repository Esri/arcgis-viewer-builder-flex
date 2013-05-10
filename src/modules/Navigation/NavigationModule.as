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
package modules.Navigation
{

import modules.IBuilderModule;
import modules.IWidgetModel;
import modules.IWidgetView;
import modules.supportClasses.XMLWidgetView;

import mx.modules.ModuleBase;
import mx.resources.ResourceManager;

public final class NavigationModule extends ModuleBase implements IBuilderModule
{
    public function get isManaged():Boolean
    {
        return false;
    }

    public function get isOpenByDefault():Boolean
    {
        return false;
    }

    public function get widgetName():String
    {
        return 'Navigation';
    }

    public function get widgetIconLocation():String
    {
        return '';
    }

    public function get widgetLabel():String
    {
        return ResourceManager.getInstance().getString('BuilderStrings', 'navigation.widgetLabel');
    }

    public function get widgetDescription():String
    {
        return ResourceManager.getInstance().getString('BuilderStrings', 'navigation.widgetDescription');
    }

    public function get widgetHelpURL():String
    {
        return ResourceManager.getInstance().getString('BuilderStrings', 'navigation.widgetHelpURL');
    }

    public function createWidgetView():IWidgetView
    {
        return new XMLWidgetView();
    }

    public function createWidgetModel():IWidgetModel
    {
        return new NavigationModel();
    }

}
}
