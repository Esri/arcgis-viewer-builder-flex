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
package modules.Print
{

import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.URLUtil;

import modules.IWidgetModel;

import mx.resources.ResourceManager;

[Bindable]
public final class PrintModel implements IWidgetModel
{
    public static const DEFAULT_DPI:Number = 96;

    private var _taskURL:String = Model.instance.printTaskURL;

    public function get taskURL():String
    {
        return _taskURL;
    }

    public function set taskURL(value:String):void
    {
        _taskURL = URLUtil.encode(value);
    }

    private var _dpi:Number = DEFAULT_DPI;

    public function get dpi():Number
    {
        return _dpi;
    }

    public function set dpi(value:Number):void
    {
        _dpi = isNaN(value) ? DEFAULT_DPI : value;
    }

    public var title:String = ResourceManager.getInstance().getString('BuilderStrings', 'print.defaultTitle');
    public var subtitle:String = ResourceManager.getInstance().getString('BuilderStrings', 'print.defaultSubtitle');
    public var copyright:String = ResourceManager.getInstance().getString('BuilderStrings', 'print.defaultCopyright');
    public var author:String = "";
    public var useScale:Boolean = true;
    public var submitLabel:String;
    public var defaultFormat:String = "";
    public var defaultLayoutTemplate:String = "";

    public var isTitleVisible:Boolean = true;
    public var isCopyrightVisible:Boolean = true;
    public var isAuthorVisible:Boolean = true;

    public var willUseExportWebMap:Boolean = false;
    public var useProxy:Boolean;

    public function importXML(doc:XML):void
    {
        if (doc.taskurl[0])
        {
            taskURL = doc.taskurl;
            willUseExportWebMap = true;
        }
        if (doc.title[0])
        {
            title = doc.title;
            isTitleVisible = (doc.title.@visible[0] != "false");
        }
        if (doc.author[0])
        {
            author = doc.author;
            isAuthorVisible = (doc.author.@visible[0] != "false");
        }
        if (doc.subtitle[0])
        {
            subtitle = doc.subtitle;
        }
        if (doc.copyright[0])
        {
            copyright = doc.copyright;
            isCopyrightVisible = (doc.copyright.@visible[0] != "false");
        }
        if (doc.usescale[0])
        {
            useScale = (doc.usescale.@visible == 'true');
        }
        if (doc.formats.@defaultvalue[0])
        {
            defaultFormat = doc.formats.@defaultvalue[0];
        }
        if (doc.layouttemplates.@defaultvalue[0])
        {
            defaultLayoutTemplate = doc.layouttemplates.@defaultvalue[0];
        }
        if (doc.useproxy[0] == "true")
        {
            useProxy = true;
        }
        if (doc.dpi[0])
        {
            dpi = parseFloat(doc.dpi[0]);
        }
    }

    public function exportXML():XML
    {
        if (willUseExportWebMap)
        {
            return createExportWebMapXML();
        }
        else
        {
            return createPrintScreenXML();
        }
    }

    private function createPrintScreenXML():XML
    {
        var configXML:XML = <configuration/>;

        if (title)
        {
            configXML.appendChild(<title>{title}</title>);
        }
        if (copyright)
        {
            configXML.appendChild(<copyright>{copyright}</copyright>);
        }
        if (subtitle)
        {
            configXML.appendChild(<subtitle>{subtitle}</subtitle>);
        }

        return configXML;
    }

    private function createExportWebMapXML():XML
    {
        var configXML:XML = <configuration/>;

        configXML.appendChild(<taskurl>{taskURL}</taskurl>);

        var titleXML:XML = <title>{title}</title>;
        titleXML.@visible = isTitleVisible;
        configXML.appendChild(titleXML);

        var copyrightXML:XML = <copyright>{copyright}</copyright>;
        copyrightXML.@visible = isCopyrightVisible;
        configXML.appendChild(copyrightXML);

        var authorXML:XML = <author>{author}</author>;
        authorXML.@visible = isAuthorVisible;
        configXML.appendChild(authorXML);

        configXML.appendChild(<dpi>{dpi}</dpi>);

        if (useScale)
        {
            configXML.appendChild(<usescale visible="true"/>);
        }

        if (defaultFormat)
        {
            configXML.appendChild(<formats defaultvalue={defaultFormat}/>)
        }

        if (defaultLayoutTemplate)
        {
            configXML.appendChild(<layouttemplates defaultvalue={defaultLayoutTemplate}/>)
        }

        if (useProxy)
        {
            configXML.appendChild(<useproxy>{useProxy}</useproxy>);
        }

        return configXML;
    }
}
}
