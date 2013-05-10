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
package modules.HeaderController
{

import com.esri.builder.supportClasses.XMLUtil;

import mx.resources.ResourceManager;

[Bindable]
public class Link
{
    public var url:String = "";
    public var label:String = "";
    public var content:String = "";
    public var contentHeight:Number;
    public var contentWidth:Number;
    public var contentCloseLabel:String = "";

    public function get type():String
    {
        return url ?
            ResourceManager.getInstance().getString('BuilderStrings', 'headerController.urlType') :
            ResourceManager.getInstance().getString('BuilderStrings', 'headerController.contentType');
    }

    public static function fromXML(linkXML:XML):Link
    {
        var link:Link;

        if (linkXML.@url[0])
        {
            link = urlLinkFromXML(linkXML);
        }
        else if (linkXML.content[0])
        {
            link = contentLinkFromXML(linkXML);
        }

        return link;
    }

    //assumes label & url are defined
    private static function urlLinkFromXML(linkXML:XML):Link
    {
        const link:Link = new Link();

        link.label = linkXML.@label[0]
            || ResourceManager.getInstance().getString('BuilderStrings', 'headerController.about');
        link.url = linkXML.@url[0];

        return link;
    }

    //assumes label & content are defined
    private static function contentLinkFromXML(linkXML:XML):Link
    {
        const link:Link = new Link();

        link.label = linkXML.@label[0]
            || ResourceManager.getInstance().getString('BuilderStrings', 'headerController.about');
        link.content = linkXML.content[0];

        if (linkXML.content.@closelabel[0])
        {
            link.contentCloseLabel = linkXML.content.@closelabel[0];
        }
        if (linkXML.content.@height[0])
        {
            link.contentHeight = linkXML.content.@height[0];
        }
        if (linkXML.content.@width[0])
        {
            link.contentWidth = linkXML.content.@width[0]
        }

        return link;
    }

    public function toXML():XML
    {
        const linkXML:XML = <link label={label}/>;

        if (url)
        {
            linkXML.@url = url;
        }
        else
        {
            linkXML.appendChild(getContentXML());
        }

        return linkXML;
    }

    private function getContentXML():XML
    {
        const contentXML:XML =
            <content closelabel={contentCloseLabel}>
                {XMLUtil.wrapInCDATA(content)}
            </content>;

        if (!isNaN(contentWidth))
        {
            contentXML.@width = contentWidth;
        }
        if (!isNaN(contentHeight))
        {
            contentXML.@height = contentHeight;
        }

        return contentXML;
    }
}
}
