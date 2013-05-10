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

import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.supportClasses.ConfigXMLUtil;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.collections.ArrayList;
import mx.resources.ResourceManager;

[Bindable]
public final class Config extends EventDispatcher
{
    // List of widgets in config.xml
    public var widgetArray:Array;
    // List of widget containers in config.xml
    public var widgetContainerArray:Array;
    public var configMap:ConfigMap;
    public var isDirty:Boolean;

    private var originalConfigXML:XML;

    private var _subTitleFontSize:int;

    public function get subTitleFontSize():int
    {
        return _subTitleFontSize;
    }

    public function set subTitleFontSize(value:int):void
    {
        _subTitleFontSize = value;
        isDirty = true;
    }

    private var _appTitleFontSize:int;

    public function get appTitleFontSize():int
    {
        return _appTitleFontSize;
    }

    public function set appTitleFontSize(value:int):void
    {
        _appTitleFontSize = value;
        isDirty = true;
    }

    private var _subTitleFontName:String;

    public function get subTitleFontName():String
    {
        return _subTitleFontName;
    }

    public function set subTitleFontName(value:String):void
    {
        _subTitleFontName = value;
        isDirty = true;
    }

    private var _appTitleFontName:String;

    public function get appTitleFontName():String
    {
        return _appTitleFontName;
    }

    public function set appTitleFontName(value:String):void
    {
        _appTitleFontName = value;
        isDirty = true;
    }

    private var _fontSize:int;

    public function get fontSize():int
    {
        return _fontSize;
    }

    public function set fontSize(value:int):void
    {
        _fontSize = value;
        isDirty = true;
    }

    private var _fontName:String;

    public function get fontName():String
    {
        return _fontName;
    }

    public function set fontName(value:String):void
    {
        _fontName = value;
        isDirty = true;
    }

    private var _alpha:Number = 1;

    public function get alpha():Number
    {
        return _alpha;
    }

    public function set alpha(value:Number):void
    {
        _alpha = value;
        isDirty = true;
    }

    private var _titleColor:Number;

    public function get titleColor():Number
    {
        return _titleColor;
    }

    public function set titleColor(value:Number):void
    {
        _titleColor = value;
        isDirty = true;
    }

    private var _selectionColor:Number;

    public function get selectionColor():Number
    {
        return _selectionColor;
    }

    public function set selectionColor(value:Number):void
    {
        _selectionColor = value;
        isDirty = true;
    }

    private var _rolloverColor:Number;

    public function get rolloverColor():Number
    {
        return _rolloverColor;
    }

    public function set rolloverColor(value:Number):void
    {
        _rolloverColor = value;
        isDirty = true;
    }

    private var _backgroundColor:Number;

    public function get backgroundColor():Number
    {
        return _backgroundColor;
    }

    public function set backgroundColor(value:Number):void
    {
        _backgroundColor = value;
        isDirty = true;
    }

    private var _textColor:Number;

    public function get textColor():Number
    {
        return _textColor;
    }

    public function set textColor(value:Number):void
    {
        _textColor = value;
        isDirty = true;
    }

    private var _splashPageURL:String;

    public function get splashPageURL():String
    {
        return _splashPageURL;
    }

    public function set splashPageURL(value:String):void
    {
        _splashPageURL = value;
        isDirty = true;
    }

    private var _splashPageConfig:String;

    public function get splashPageConfig():String
    {
        return _splashPageConfig;
    }

    public function set splashPageConfig(value:String):void
    {
        _splashPageConfig = value;
        isDirty = true;
    }

    private var _splashPageLabel:String;

    public function get splashPageLabel():String
    {
        return _splashPageLabel;
    }

    public function set splashPageLabel(value:String):void
    {
        _splashPageLabel = value;
        isDirty = true;
    }

    private var _logo:String;

    [Bindable(event="configParsed")]
    public function get logo():String
    {
        return _logo;
    }

    public function set logo(value:String):void
    {
        _logo = value;
        isDirty = true;
    }

    private var _subTitle:String;

    [Bindable(event="configParsed")]
    public function get subTitle():String
    {
        return _subTitle;
    }

    public function set subTitle(value:String):void
    {
        _subTitle = value;
        isDirty = true;
    }

    private var _appTitle:String;

    [Bindable(event="configParsed")]
    public function get appTitle():String
    {
        return _appTitle;
    }

    public function set appTitle(value:String):void
    {
        _appTitle = value;
        isDirty = true;
    }

    public function toConfigXML():XML
    {
        var configXML:XML = originalConfigXML;
        var httpProxyXML:XML = null;
        if (Model.instance.proxyURL)
        {
            httpProxyXML = <httpproxy>{Model.instance.proxyURL}</httpproxy>;
        }
        ConfigXMLUtil.mergeChild(configXML, "httpproxy", httpProxyXML);

        var logoXML:XML = null;
        if (logo)
        {
            logoXML = <logo>{logo}</logo>;
        }
        ConfigXMLUtil.mergeChild(configXML, "logo", logoXML);

        var appTitleXML:XML = null;
        if (appTitle)
        {
            appTitleXML = <title>{appTitle}</title>;
        }
        ConfigXMLUtil.mergeChild(configXML, "title", appTitleXML);

        var subTitleXML:XML = null;
        if (subTitle)
        {
            subTitleXML = <subtitle>{subTitle}</subtitle>;
        }
        ConfigXMLUtil.mergeChild(configXML, "subtitle", subTitleXML);

        mergeStyle(configXML);
        mergeGeometryService(configXML);
        mergeSplashPage(configXML);
        mergeBing(configXML);
        mergeWidgets(configXML);
        mergeWidgetContainers(configXML);
        mergeMap(configXML);

        return configXML;
    }

    private function mergeMap(configXML:XML):void
    {
        delete configXML.map;
        var mapXML:XML = null;
        if (configMap)
        {
            mapXML = configMap.encodeXML();
        }

        if (mapXML == null)
        {
            return;
        }
        if (configXML.hasOwnProperty("widget"))
        {
            var widgetChildren:XMLList = configXML.child("widget");
            configXML.insertChildAfter(widgetChildren[widgetChildren.length() - 1], mapXML);
        }
        else
        {
            configXML.appendChild(mapXML);
        }
    }

    private function mergeWidgetContainers(configXML:XML):void
    {
//        if (widgetContainerArray.length == 1 && configXML.hasOwnProperty("widgetcontainer"))
//        {
//            (widgetContainerArray[0] as WidgetContainer).encodeXML(configXML.child("widgetcontainer")[0]);
//            return;
//        }

        delete configXML.widgetcontainer;
        for each (var widgetContainer:WidgetContainer in widgetContainerArray)
        {
            configXML.appendChild(widgetContainer.encodeXML());
        }
    }

    private function mergeWidgets(configXML:XML):void
    {
        removeOriginalWidgets(configXML);
        delete configXML.widget;

        var widgetXMLList:XMLList = configXML.child("widget");
        for each (var widget:Widget in widgetArray)
        {
            var originalWidgetXML:XML = null;
            for each (var temp:XML in widgetXMLList)
            {
                if (temp.@url == widget.url)
                {
                    originalWidgetXML = temp;
                    break;
                }
            }
            if (originalWidgetXML == null)
            {
                configXML.appendChild(widget.encodeXML());
            }
            else
            {
                widget.encodeXML(originalWidgetXML);
            }
        }
    }

    private function removeOriginalWidgets(configXML:XML):void
    {
        var widgetXMLList:XMLList = configXML.child("widget");
        var toremove:Array = new Array();
        for (var i:int = 0; i < widgetXMLList.length(); i++)
        {
            var temp:XML = widgetXMLList[i];
            var found:Boolean = false;
            for each (var widget:Widget in widgetArray)
            {
                if (widget.url == temp.@url)
                {
                    found = true;
                    break;
                }
            }

            if (!found)
            {
                toremove.push(i);
            }
        }

        for (var j:int = toremove.length - 1; j >= 0; j--)
        {
            delete widgetXMLList[j];
        }
    }

    private function mergeBing(configXML:XML):void
    {
        var bingKeyXML:XML = null;
        if (Model.instance.bingKey)
        {
            bingKeyXML = <bing key={Model.instance.bingKey}/>;
        }
        ConfigXMLUtil.mergeChild(configXML, "bing", bingKeyXML);
    }

    private function mergeSplashPage(configXML:XML):void
    {
        var splashPageXML:XML = null;
        if (splashPageURL)
        {
            splashPageXML = <splashpage url={splashPageURL}/>;
            if (splashPageLabel)
            {
                splashPageXML.@label = splashPageLabel;
            }
            if (splashPageConfig)
            {
                splashPageXML.@config = splashPageConfig;
            }
        }
        ConfigXMLUtil.mergeChild(configXML, "splashpage", splashPageXML);
    }

    private function mergeGeometryService(configXML:XML):void
    {
        var geometryServiceXML:XML = null;
        if (Model.instance.geometryServiceURL)
        {
            geometryServiceXML = <geometryservice url={Model.instance.geometryServiceURL}/>;
        }

        ConfigXMLUtil.mergeChild(configXML, "geometryservice", geometryServiceXML);
    }

    private function mergeStyle(configXML:XML):void
    {
        var styleXML:XML = null;
        if (configXML.hasOwnProperty("style"))
        {
            styleXML = configXML.child("style")[0];
        }
        else
        {
            styleXML = <style/>;
            configXML.appendChild(styleXML);
        }

        ConfigXMLUtil.mergeChild(styleXML, "alpha", <alpha>{alpha}</alpha>);

        mergeColors(styleXML);

        var fontXML:XML = null;
        if (fontName && fontSize)
        {
            fontXML = <font name={fontName} size={fontSize}/>;
        }
        else if (fontName)
        {
            fontXML = <font name={fontName}/>;
        }
        else if (fontSize)
        {
            fontXML = <font size={fontSize}/>;
        }
        ConfigXMLUtil.mergeChild(styleXML, "font", fontXML);

        var titleFontXML:XML = null;
        if (appTitleFontName && appTitleFontSize)
        {
            titleFontXML = <titlefont name={appTitleFontName} size={appTitleFontSize}/>;
        }
        else if (appTitleFontName)
        {
            titleFontXML = <titlefont name={appTitleFontName}/>;
        }
        else if (appTitleFontSize)
        {
            titleFontXML = <titlefont size={appTitleFontSize}/>;
        }
        ConfigXMLUtil.mergeChild(styleXML, "titlefont", titleFontXML);

        var subTitleFontXML:XML = null;
        if (subTitleFontName && subTitleFontSize)
        {
            subTitleFontXML = <subtitlefont name={subTitleFontName} size={subTitleFontSize}/>;
        }
        else if (subTitleFontName)
        {
            subTitleFontXML = <subtitlefont name={subTitleFontName}/>;
        }
        else if (subTitleFontSize)
        {
            subTitleFontXML = <subtitlefont size={subTitleFontSize}/>;
        }
        ConfigXMLUtil.mergeChild(styleXML, "subtitlefont", subTitleFontXML);
    }

    private function mergeColors(styleXML:XML):void
    {
        const arr:Array = [];
        if (isNaN(textColor))
        {
            arr.push('0xFFFFFF');
        }
        else
        {
            arr.push('0x' + textColor.toString(16));
        }
        if (isNaN(backgroundColor))
        {
            arr.push('0x333333');
        }
        else
        {
            arr.push('0x' + backgroundColor.toString(16));
        }
        if (isNaN(rolloverColor))
        {
            arr.push('0x101010');
        }
        else
        {
            arr.push('0x' + rolloverColor.toString(16));
        }
        if (isNaN(selectionColor))
        {
            arr.push('0x000000');
        }
        else
        {
            arr.push('0x' + selectionColor.toString(16));
        }
        if (isNaN(titleColor))
        {
            arr.push('0xFFD700');
        }
        else
        {
            arr.push('0x' + titleColor.toString(16));
        }
        const colors:String = arr.join(',');

        var colorsXML:XML = <colors>{colors}</colors>;
        ConfigXMLUtil.mergeChild(styleXML, "colors", colorsXML);
    }

    private function parseConfigXML(configXML:XML):void
    {
        _appTitle = configXML.title;
        _subTitle = configXML.subtitle;
        _logo = configXML.logo;
        parseStyle(configXML);
        parseSplashPage(configXML);
        parseWidgets(configXML);
        parseWidgetContainer(configXML);
        parseMap(configXML);
    }

    private function parseMap(configXML:XML):void
    {
        const mapXMLList:XMLList = configXML.map;
        if (mapXMLList.length())
        {
            this.configMap = ConfigMap.decodeXML(mapXMLList[0]);
        }
        else
        {
            this.configMap = new ConfigMap();
        }
    }

    private function parseSplashPage(configXML:XML):void
    {
        const splashpageXMLList:XMLList = configXML.splashpage;
        if (splashpageXMLList.length())
        {
            const splashpageXML:XML = splashpageXMLList[0];
            _splashPageConfig = splashpageXML.@config;
            _splashPageLabel = splashpageXML.@label;
            _splashPageURL = splashpageXML.@url;
        }
    }

    private function parseStyle(configXML:XML):void
    {
        const styleXML:XML = configXML.style[0];
        if (styleXML)
        {
            const colorsText:String = styleXML.colors;
            const colorsArr:Array = colorsText.split(',');
            if (colorsArr.length === 5)
            {
                _textColor = uint(colorsArr[0]);
                _backgroundColor = uint(colorsArr[1]);
                _rolloverColor = uint(colorsArr[2]);
                _selectionColor = uint(colorsArr[3]);
                _titleColor = uint(colorsArr[4]);
            }

            const parsedAlpha:Number = parseFloat(styleXML.alpha[0]);
            _alpha = isNaN(parsedAlpha) ? 1.0 : parsedAlpha;

            const fontXML:XML = styleXML.font[0];
            _fontName = fontXML ? fontXML.@name : ResourceManager.getInstance().getString('BuilderStrings', 'titlesWindow.font1');
            _fontSize = fontXML ? fontXML.@size : 0;

            const titleFontXML:XML = styleXML.titlefont[0];
            _appTitleFontName = titleFontXML ? titleFontXML.@name : ResourceManager.getInstance().getString('BuilderStrings', 'titlesWindow.font1');
            _appTitleFontSize = titleFontXML ? titleFontXML.@size : 0;

            const subTitleFontXML:XML = styleXML.subtitlefont[0];
            _subTitleFontName = subTitleFontXML ? subTitleFontXML.@name : ResourceManager.getInstance().getString('BuilderStrings', 'titlesWindow.font1');
            _subTitleFontSize = subTitleFontXML ? subTitleFontXML.@size : 0;
        }
    }

    private function parseWidgetContainer(configXML:XML):void
    {
        const widgetContainerArr:Array = [];
        for each (var widgetContainerXML:XML in configXML.widgetcontainer)
        {
            widgetContainerArr.push(WidgetContainer.decodeXML(widgetContainerXML));
        }

        Model.instance.widgetList = new ArrayList();
        Model.instance.bottomPanelWidgetList = new ArrayList();
        Model.instance.leftPanelWidgetList = new ArrayList();
        Model.instance.rightPanelWidgetList = new ArrayList();
        if (widgetContainerArr.length)
        {
            for each (var widgetContainer:WidgetContainer in widgetContainerArr)
            {
                if (widgetContainer.panelType)
                {
                    if (widgetContainer.panelType == "bottom")
                    {
                        Model.instance.bottomPanelWidgetList.source = widgetContainer.children;
                    }
                    else if (widgetContainer.panelType == "left")
                    {
                        Model.instance.leftPanelWidgetList.source = widgetContainer.children;
                    }
                    else if (widgetContainer.panelType == "right")
                    {
                        Model.instance.rightPanelWidgetList.source = widgetContainer.children;
                    }
                }
                else
                {
                    Model.instance.widgetList.source = widgetContainer.children;
                }
            }
        }
        this.widgetContainerArray = widgetContainerArr;
    }

    private function parseWidgets(configXML:XML):void
    {
        const widgetArr:Array = [];
        for each (var widgetXML:XML in configXML.widget)
        {
            widgetArr.push(Widget.decodeXML(widgetXML, false, false));
        }

        this.widgetArray = widgetArr;
        Model.instance.layoutWidgetList = new ArrayList(widgetArr);
    }

    // TODO - fix this where there is _no_ Model reference.
    public function readConfigXML():Boolean
    {
        var success:Boolean = false;
        const configFile:File = Model.instance.appDir.resolvePath('config.xml');
        if (configFile.exists)
        {
            const fileStream:FileStream = new FileStream();
            try
            {
                XML.ignoreComments = false;
                fileStream.open(configFile, FileMode.READ);
                const configXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
                parseConfigXML(configXML);
                Model.instance.configBasemapsList.importLayers(configMap.basemaps.getAllLayers());
                Model.instance.configOpsLayerList.importLayers(configMap.operationalLayers.getAllLayers());
                originalConfigXML = configXML;
                success = true;

                dispatchEvent(new Event("configParsed"));
                AppEvent.dispatch(AppEvent.LOAD_WEB_MAP); // load web map if there is an itemid
            }
            catch (e:Error)
            {
                // NOOP - XML error
            }
            finally
            {
                fileStream.close();
                XML.ignoreComments = true;
            }
        }
        return success;
    }
}
}
