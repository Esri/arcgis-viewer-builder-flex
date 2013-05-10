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
package modules
{

import mx.core.IVisualElement;

/**
 * All modules that will be loaded by the Builder should implement this interface.
 */
public interface IBuilderModule
{
    /**
     * Should this widget be managed by a container
     */
    function get isManaged():Boolean;

    /**
     * Should this widget be open by default
     */
    function get isOpenByDefault():Boolean;

    /**
     * The widget icon location.
     */
    function get widgetIconLocation():String;

    /**
     * The internal name of the widget.
     */
    function get widgetName():String;

    /**
     * The widget label.
     * This is the public facing name of the widget.
     * This value should be localized.
     */
    function get widgetLabel():String;

    /**
     * The widget description.
     * This value should be localized.
     */
    function get widgetDescription():String;

    /**
     * The widget help URL.
     * This value should be localized.
     */
    function get widgetHelpURL():String;

    /**
     * Create a IWidgetView instance.
     */
    function createWidgetView():IWidgetView;

    /**
     * Create a IWidgetModel instance.
     */
    function createWidgetModel():IWidgetModel;

/* TODO
function get widgetLeft():Number;

function get widgetRight():Number;

function get widgetTop():Number;

function get widgetBottom():Number;
*/

}
}
