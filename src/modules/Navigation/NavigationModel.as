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

import modules.IWidgetModel;

public final class NavigationModel implements IWidgetModel
{
    [Bindable]
    public var panWheelVisible:Boolean = true;
    [Bindable]
    public var prevExtButtonVisible:Boolean = true;
    [Bindable]
    public var nextExtButtonVisible:Boolean = true;
    [Bindable]
    public var panButtonVisible:Boolean = true;
    [Bindable]
    public var zoomInButtonVisible:Boolean = true;
    [Bindable]
    public var zoomOutButtonVisible:Boolean = true;
    [Bindable]
    public var panWheelIconURL:String = "assets/images/i_globe.png";
    [Bindable]
    public var panButtonIconURL:String = "assets/images/i_pan.png";
    [Bindable]
    public var zoomInButtonIconURL:String = "assets/images/i_zoomin.png";
    [Bindable]
    public var zoomOutButtonIconURL:String = "assets/images/i_zoomout.png";

    public function importXML(doc:XML):void
    {
        //TODO: null check
        panWheelVisible = (doc.panwheel.@visible == "true");
        panWheelIconURL = doc.panwheel.@fullexticon;
        prevExtButtonVisible = (doc.prevextbutton.@visible == "true");
        nextExtButtonVisible = (doc.nextextbutton.@visible == "true");
        panButtonVisible = (doc.panbutton.@visible == "true");
        panButtonIconURL = doc.panbutton.@icon;
        zoomInButtonVisible = (doc.zoominbutton.@visible == "true");
        zoomInButtonIconURL = doc.zoominbutton.@icon;
        zoomOutButtonVisible = (doc.zoomoutbutton.@visible == "true");
        zoomOutButtonIconURL = doc.zoomoutbutton.@icon;
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <panwheel/>
                <prevextbutton/>
                <nextextbutton/>
                <panbutton/>
                <zoominbutton/>
                <zoomoutbutton/>
            </configuration>;

        configXML.panwheel.@visible = panWheelVisible;
        configXML.panwheel.@fullexticon = panWheelIconURL;
        configXML.prevextbutton.@visible = prevExtButtonVisible;
        configXML.nextextbutton.@visible = nextExtButtonVisible;
        configXML.panbutton.@visible = panButtonVisible;
        configXML.panbutton.@icon = panButtonIconURL;
        configXML.zoominbutton.@visible = zoomInButtonVisible;
        configXML.zoominbutton.@icon = zoomInButtonIconURL;
        configXML.zoomoutbutton.@visible = zoomOutButtonVisible;
        configXML.zoomoutbutton.@icon = zoomOutButtonIconURL;

        return configXML;
    }
}
}
