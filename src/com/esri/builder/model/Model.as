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
package com.esri.builder.model
{

import com.esri.ags.geometry.Extent;
import com.esri.ags.portal.supportClasses.PortalItem;
import com.esri.ags.tasks.GeometryServiceSingleton;
import com.esri.builder.supportClasses.URLUtil;
import com.esri.builder.controllers.supportClasses.Settings;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.BasemapConfigLayerStore;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.utils.StringUtil;

public final class Model extends EventDispatcher
{
    public static const USER_PREF:String = 'userPref';

    public static const TEMP_DIR_NAME:String = "__temp__";

    public static const REQUEST_TIMEOUT:int = 30;

    public static const instance:Model = new Model();

    public static const SUPPORTED_VIEWER_VERSION:Number = 3.7;

    [Bindable]
    public var config:Config = new Config();

    [Bindable]
    public var status:String = '';

    private var _appState:String = 'intro';

    [Bindable]
    public function get appState():String
    {
        return _appState;
    }

    public function set appState(value:String):void
    {
        _appState = value;
        AppEvent.dispatch(AppEvent.APP_STATE_CHANGED, _appState);
    }

    private var _webServerURL:String;

    [Bindable("webServerURLChanged")]
    public function get webServerURL():String
    {
        return _webServerURL;
    }

    private function setWebServerURL(value:String):void
    {
        _webServerURL = URLUtil.encode(value);
        dispatchEvent(new Event("webServerURLChanged"));
    }

    private var _webServerFolder:String;

    [Bindable("webServerFolderChanged")]
    public function get webServerFolder():String
    {
        return _webServerFolder;
    }

    private function setWebServerFolder(value:String):void
    {
        _webServerFolder = value;
        dispatchEvent(new Event("webServerFolderChanged"));
    }

    private var _baseDir:File;

    public function get baseDir():File
    {
        return _baseDir;
    }

    private var _locale:String;

    [Bindable("localeChanged")]
    public function get locale():String
    {
        return _locale ||= "en_US";
    }

    private var _bingKey:String;

    [Bindable("bingKeyChanged")]
    public function get bingKey():String
    {
        return _bingKey;
    }

    private function setBingKey(value:String):void
    {
        _bingKey = value;
        dispatchEvent(new Event("bingKeyChanged"));
    }

    private var _proxyURL:String;

    [Bindable("proxyURLChanged")]
    public function get proxyURL():String
    {
        return _proxyURL;
    }

    private function setProxyURL(value:String):void
    {
        _proxyURL = URLUtil.encode(value);
        dispatchEvent(new Event("proxyURLChanged"));
    }

    private var _geometryServiceURL:String;

    [Bindable("geometryServiceURLChanged")]
    public function get geometryServiceURL():String
    {
        return _geometryServiceURL;
    }

    private function setGeometryServiceURL(value:String):void
    {
        _geometryServiceURL = URLUtil.encode(StringUtil.trim(value));
        GeometryServiceSingleton.instance.url = _geometryServiceURL;
        dispatchEvent(new Event("geometryServiceURLChanged"));
    }

    private var _geocodeURL:String;

    [Bindable("geocodeURLChanged")]
    public function get geocodeURL():String
    {
        return _geocodeURL;
    }

    private function setGeocodeURL(value:String):void
    {
        _geocodeURL = URLUtil.encode(StringUtil.trim(value));
        dispatchEvent(new Event("geocodeURLChanged"));
    }

    private var _directionsURL:String;

    [Bindable("directionsURLChanged")]
    public function get directionsURL():String
    {
        return _directionsURL;
    }

    private function setDirectionsURL(value:String):void
    {
        _directionsURL = URLUtil.encode(StringUtil.trim(value));
        dispatchEvent(new Event("directionsURLChanged"));
    }

    private var _printTaskURL:String;

    [Bindable("printTaskURLChanged")]
    public function get printTaskURL():String
    {
        return _printTaskURL;
    }

    private function setPrintTaskURL(value:String):void
    {
        _printTaskURL = URLUtil.encode(StringUtil.trim(value));
        dispatchEvent(new Event("printTaskURLChanged"));
    }

    private var _isTutorialModeEnabled:Boolean;

    [Bindable("isTutorialModeEnabledChanged")]
    public function get isTutorialModeEnabled():Boolean
    {
        return _isTutorialModeEnabled;
    }

    private function setIsTutorialModeEnabled(value:Boolean):void
    {
        _isTutorialModeEnabled = value;
        dispatchEvent(new Event("isTutorialModeEnabledChanged"));
    }

    private function setLocale(value:String):void
    {
        _locale = value;
        dispatchEvent(new Event("localeChanged"));
    }

    /*Helper method to get culture code from app locale*/
    public function get cultureCode():String
    {
        return locale.replace('_', '-');
    }

    public var appDir:File;

    [Bindable]
    public var appName:String;

    [Bindable]
    public var basemapList:ArrayList;

    [Bindable]
    public var webmapState:String = 'featuredmaps';

    [Bindable]
    public var portalLayersState:String = 'featuredlayers';

    [Bindable]
    public var webmapAddEnabled:Boolean = false;

    [Bindable]
    public var arcgisQuery:String = 'http://sampleserver1.arcgisonline.com/ArcGIS/rest/services';

    [Bindable]
    public var arcgisState:String = 'loaded';

    private var _webmap:PortalItem;

    [Bindable]
    public function get webmap():PortalItem
    {
        return _webmap;
    }

    public function set webmap(value:PortalItem):void
    {
        _webmap = value;
        AppEvent.dispatch(AppEvent.WEB_MAP_CHANGE, webmap);
    }

    [Bindable]
    public var portalLayerList:ArrayList;

    [Bindable]
    public var widgetList:ArrayList = new ArrayList();

    [Bindable]
    public var bottomPanelWidgetList:ArrayList = new ArrayList();

    [Bindable]
    public var leftPanelWidgetList:ArrayList = new ArrayList();

    [Bindable]
    public var rightPanelWidgetList:ArrayList = new ArrayList();

    [Bindable]
    public var layoutWidgetList:ArrayList = new ArrayList();

    [Bindable]
    public var widgetType:WidgetType;

    [Bindable]
    public var logArrCol:ArrayCollection = new ArrayCollection(); // Using ArrCol for its built-in filter function.

    private var _viewerAppList:ArrayCollection = new ArrayCollection();

    [Bindable]
    public var lastSavedExtent:Extent;

    public function importSettings(settings:Settings):void
    {
        setWebServerFolder(settings.webServerFolder);
        setWebServerURL(settings.webServerURL);
        setGeometryServiceURL(settings.geometryServiceURL);
        setBingKey(settings.bingKey);
        setProxyURL(settings.proxyURL);
        setIsTutorialModeEnabled(settings.isTutorialModeEnabled);
        setLocale(settings.locale);
        PortalModel.getInstance().portalURL = settings.portalURL;
        if (settings.portalURL)
        {
            setGeocodeURL(settings.geocodeURL);
            setDirectionsURL(settings.directionsURL);
            setPrintTaskURL(settings.printTaskURL);
        }
        else
        {
            setGeocodeURL("");
            setDirectionsURL("");
            setPrintTaskURL("");
        }

        _baseDir = new File(settings.webServerFolder);
    }

    public function exportSettings():Settings
    {
        var settings:Settings = new Settings();

        settings.webServerFolder = webServerFolder;
        settings.webServerURL = webServerURL;
        settings.geometryServiceURL = geometryServiceURL;
        settings.geocodeURL = geocodeURL;
        settings.directionsURL = directionsURL;
        settings.printTaskURL = printTaskURL;
        settings.bingKey = bingKey;
        settings.proxyURL = proxyURL;
        settings.isTutorialModeEnabled = isTutorialModeEnabled;
        settings.locale = locale;
        settings.portalURL = PortalModel.getInstance().portalURL;
        if (PortalModel.getInstance().portalURL)
        {
            settings.geocodeURL = geocodeURL;
            settings.directionsURL = directionsURL;
            settings.printTaskURL = printTaskURL;
        }

        return settings;
    }

    [Bindable]
    public var webMapConfigBasemapList:ConfigLayerStore = new ConfigLayerStore();

    [Bindable]
    public var webMapConfigOpLayerList:ConfigLayerStore = new ConfigLayerStore();

    [Bindable]
    public function get viewerAppList():ArrayCollection
    {
        return _viewerAppList;
    }

    public function set viewerAppList(value:ArrayCollection):void
    {
        _viewerAppList = value;
    }

    [Bindable]
    public var widgetsWindowState:String = 'main';

    [Bindable]
    public var htmlLocation:String = '';

    [Bindable]
    public var configBasemapsList:BasemapConfigLayerStore = new BasemapConfigLayerStore();

    [Bindable]
    public var configOpsLayerList:ConfigLayerStore = new ConfigLayerStore();

    [Bindable]
    public var configLayer:ConfigLayer;

    [Bindable]
    public var layersState:String = 'normal';

    [Bindable]
    public var webMapSearchHistory:Array;

    [Bindable]
    public var layerSearchHistory:Array;

    public function getAllLayers():Array
    {
        return getBasemapLayers().concat(getOpLayers());
    }

    public function getBasemapLayers():Array
    {
        return webmap ? webMapConfigBasemapList.getAllLayers() : configBasemapsList.getAllLayers();
    }

    public function getOpLayers():Array
    {
        return webmap ? webMapConfigOpLayerList.getAllLayers() : configOpsLayerList.getAllLayers();
    }
}
}
