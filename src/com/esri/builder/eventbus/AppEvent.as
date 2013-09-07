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
package com.esri.builder.eventbus
{

import flash.events.Event;

/**
 * AppEvent is used within the application to send messages among components
 * through the EventBus.
 *
 * <p>The typical way of sending a message via the AppEvent is, for example:</p>
 *
 * <listing>
 *   AppEvent.dispatch(AppEvent.SHOW_ERROR, "Error message"));
 * </listing>
 *
 * <p>The typical way of receiving a message via the AppEvent is, for example:</p>
 * <listing>
 *   AppEvent.addListener(AppEvent.SHOW_ERROR, showErrorHandler);
 * </listing>
 *
 * @see EventBus
 */
public class AppEvent extends Event
{
    public static const SHOW_ERROR:String = "SHOW_ERROR";
    public static const APPLICATION_COMPLETE:String = "APPLICATION_COMPLETE";
    public static const CREATION_COMPLETE:String = "CREATION_COMPLETE";
    public static const ADD_BASEMAP:String = "ADD_BASEMAP";
    public static const EDIT_CONFIG_LAYER:String = "EDIT_CONFIG_LAYER";
    public static const ADD_MAP_SERVICE:String = "ADD_MAP_SERVICE";
    public static const MAP_SERVICE_ADDED:String = "MAP_SERVICE_ADDED";
    public static const ADD_LAYER_SERVICE:String = "ADD_LAYER_SERVICE";
    public static const LAYER_SERVICE_ADDED:String = "LAYER_SERVICE_ADDED";
    public static const SAVE_SETTINGS:String = "SAVE_SETTINGS";
    public static const SETTINGS_SAVED:String = "SETTINGS_SAVED";
    public static const LOAD_APP:String = "LOAD_APP";
    public static const EDIT_APP:String = "EDIT_APP";
    public static const APP_READY_TO_EDIT:String = "APP_READY_TO_EDIT";
    public static const CREATE_APP:String = "CREATE_APP";
    public static const APP_CREATED:String = "APP_CREATED";
    public static const CREATE_EXECUTE:String = "CREATE_EXECUTE";
    public static const DELETE_APP:String = "DELETE_APP";
    public static const DELETE_EXECUTE:String = "DELETE_EXECUTE";
    public static const RENAME_APP:String = "RENAME_APP";
    public static const RENAME_EXECUTE:String = "RENAME_EXECUTE";
    public static const LIST_APP:String = "LIST_APP";
    public static const APP_FOLDER_LISTED:String = "APP_FOLDER_LISTED";
    public static const APP_FOLDER_ITEM_PROCESSED:String = "APP_FOLDER_ITEM_PROCESSED";
    public static const LOAD_WEB_MAP:String = "LOAD_WEB_MAP";
    public static const LOAD_LAYERS:String = "LOAD_LAYERS";
    public static const SAVE_CONFIG_XML:String = "SAVE_CONFIG_XML";
    public static const CONFIG_XML_SAVED:String = "CONFIG_XML_SAVED";
    public static const WIDGET_CONFIG_XML_SAVED:String = "WIDGET_CONFIG_XML_SAVED";
    public static const WEB_MAP_SEARCH:String = "WEB_MAP_SEARCH";
    public static const SET_WEB_MAP:String = "SET_WEB_MAP";
    public static const WEB_MAP_CHANGE:String = "WEB_MAP_CHANGE";
    public static const LOGO_EXECUTE:String = "LOGO_EXECUTE";
    public static const CHANGE_TEXT_COLOR:String = "CHANGE_TEXT_COLOR";
    public static const CHANGE_BACKGROUND_COLOR:String = "CHANGE_BACKGROUND_COLOR";
    public static const CHANGE_ROLLOVER_COLOR:String = "CHANGE_ROLLOVER_COLOR";
    public static const CHANGE_SELECTION_COLOR:String = "CHANGE_SELECTION_COLOR";
    public static const CHANGE_TITLE_COLOR:String = "CHANGE_TITLE_COLOR";
    public static const CHANGE_ALPHA:String = "CHANGE_ALPHA";
    public static const CHANGE_FONT_NAME:String = "CHANGE_FONT_NAME";
    public static const CHANGE_APP_TITLE_FONT_NAME:String = "CHANGE_APP_TITLE_FONT_NAME";
    public static const CHANGE_SUB_TITLE_FONT_NAME:String = "CHANGE_SUB_TITLE_FONT_NAME";
    public static const SET_PREDEFINED_STYLES:String = "SET_PREDEFINED_STYLES";
    public static const TITLES_EXECUTE:String = "TITLES_EXECUTE";
    public static const DUPLICATE_APP:String = "DUPLICATE_APP";
    public static const DUPLICATE_EXECUTE:String = "DUPLICATE_EXECUTE";
    public static const APP_SELECTED:String = "APP_SELECTED";
    public static const RENAME_APP_SELECTED:String = "RENAME_APP_SELECTED";
    public static const DELETE_APP_SELECTED:String = "DELETE_APP_SELECTED";
    public static const DUPLICATE_APP_SELECTED:String = "DUPLICATE_APP_SELECTED";
    public static const EXPORT_APP_SELECTED:String = "EXPORT_APP_SELECTED";
    public static const UPGRADE_APP_SELECTED:String = "UPGRADE_APP_SELECTED";
    public static const UPGRADE_APP:String = "UPGRADE_APP";
    public static const UPGRADE_APP_COMPLETE:String = "UPGRADE_APP_COMPLETE";
    public static const UPGRADE_APP_FAILED:String = "UPGRADE_APP_FAILED";
    public static const APP_MENU_OPENED:String = "APP_MENU_OPENED";
    public static const APP_STATE_CHANGED:String = "APP_STATE_CHANGED";
    public static const BREADCRUMB_SELECTED:String = "BREADCRUMB_SELECTED";
    public static const PREVIEW_APP_IN_BROWSER_SELECTED:String = "PREVIEW_APP_IN_BROWSER_SELECTED";
    public static const EXPORT_WINDOW:String = "EXPORT_WINDOW";
    public static const EXPORT_EXECUTE:String = "EXPORT_EXECUTE";
    public static const SAVE_CHANGES:String = "SAVE_CHANGES";
    public static const CHANGES_SAVED:String = "CHANGES_SAVED";
    public static const SWITCH_MAPS:String = "SWITCH_MAPS";
    public static const MAPS_SWITCHED:String = "MAPS_SWITCHED";
    public static const EDIT_WIDGET:String = "EDIT_WIDGET";
    public static const EDIT_PANEL_WIDGET:String = "EDIT_PANEL_WIDGET";
    public static const DELETE_WIDGET:String = "DELETE_WIDGET";
    public static const DELETE_PANEL_WIDGET:String = "DELETE_PANEL_WIDGET";
    public static const TUTORIAL_MODE_SETTINGS_CHANGED:String = "TUTORIAL_MODE_SETTINGS_CHANGED";
    public static const REGISTER_URL:String = "REGISTER_URL";
    public static const BASEMAP_AND_OP_LAYERS_SELECTED:String = "BASEMAP_AND_OP_LAYERS_SELECTED";
    public static const WEB_MAP_SELECTED:String = "WEB_MAP_SELECTED";
    public static const IMPORT_CUSTOM_WIDGET:String = "IMPORT_CUSTOM_WIDGET";
    public static const IMPORT_WIDGET_SUCCESS:String = "IMPORT_WIDGET_SUCCESS";
    public static const IMPORT_WIDGET_FAILURE:String = "IMPORT_WIDGET_FAILURE";
    public static const WIDGET_ADDED_TO_APP:String = "WIDGET_ADDED_TO_APP";
    public static const PORTAL_LAYER_SEARCH:String = "PORTAL_LAYER_SEARCH";
    public static const PORTAL_OPEN_GROUP:String = "PORTAL_OPEN_GROUP";
    public static const PORTAL_STATUS_UPDATED:String = "PORTAL_STATUS_UPDATED";
    public static const PORTAL_SIGN_IN:String = "PORTAL_SIGN_IN";
    public static const PORTAL_SIGN_OUT:String = "PORTAL_SIGN_OUT";
    public static const REMOVE_CUSTOM_WIDGET:String = "REMOVE_CUSTOM_WIDGET";
    public static const REMOVE_CUSTOM_WIDGET_SUCCESS:String = "REMOVE_CUSTOM_WIDGET_SUCCESS";
    public static const REMOVE_CUSTOM_WIDGET_FAILURE:String = "REMOVE_CUSTOM_WIDGET_FAILURE";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function AppEvent(type:String, data:Object = null, callback:Function = null, cancelable:Boolean = false)
    {
        super(type, false, cancelable);
        _data = data;
        _callback = callback;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    private var _data:Object;

    private var _callback:Function;

    /**
     * The data will be passed via the event. It allows the event dispatcher to publish
     * data to event listener(s).
     */
    public function get data():Object
    {
        return _data;
    }

    /**
     * @private
     */
    public function set data(value:Object):void
    {
        _data = value;
    }

    /**
     * The callback function associated with this event.
     */
    public function get callback():Function
    {
        return _callback;
    }

    /**
     * @private
     */
    public function set callback(value:Function):void
    {
        _callback = value;
    }

    /**
     * Override clone
     */
    public override function clone():Event
    {
        return new AppEvent(this.type, this.data, this.callback);
    }

    /**
     * Dispatch this event.
     */
    public function dispatch():Boolean
    {
        return EventBus.instance.dispatchEvent(this);
    }

    /**
     * Dispatch an AppEvent for specified type and with optional data and callback reference.
     */
    public static function dispatch(type:String, data:Object = null, callback:Function = null, cancelable:Boolean = false):Boolean
    {
        return EventBus.instance.dispatchEvent(new AppEvent(type, data, callback, cancelable));
    }

    public static function addListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        EventBus.instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    public static function removeListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        EventBus.instance.removeEventListener(type, listener, useCapture);
    }
}

}
