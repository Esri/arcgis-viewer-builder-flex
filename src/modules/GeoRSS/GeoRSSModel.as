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
package modules.GeoRSS
{

import com.esri.builder.supportClasses.URLUtil;

import modules.IWidgetModel;

import mx.resources.ResourceManager;

[Bindable]
public final class GeoRSSModel implements IWidgetModel
{
    private var _source:String = "http://earthquake.usgs.gov/earthquakes/feed/atom/4.5/week";

    public function get source():String
    {
        return _source;
    }

    public function set source(value:String):void
    {
        _source = URLUtil.encode(value);
    }

    public var fieldName:String = "description";
    public var fieldAlias:String = ResourceManager.getInstance().getString('BuilderStrings', 'georss.defaultFieldAlias');
    public var titleField:String = "title";
    public var linkField:String = "link";
    public var refreshRate:String = "";
    public var zoomScale:String = "15000";
    public var useProxy:Boolean;
    public var pictureMarkerSymbolURL:String = "assets/images/i_rss.png";

    public function importXML(doc:XML):void
    {
        if (!doc)
        {
            return;
        }

        source = doc.source;
        fieldName = doc.fields.field[0].@name;
        fieldAlias = doc.fields.field[0].@alias;
        titleField = doc.titlefield;
        linkField = doc.linkfield;
        useProxy = (doc.useproxy == 'true');

        var isRefreshRateANumber:Boolean = (doc.refreshrate[0] && !isNaN(parseFloat(doc.refreshrate)));
        if (isRefreshRateANumber)
        {
            refreshRate = doc.refreshrate;
        }

        var isZoomScaleANumber:Boolean = (doc.zoomscale[0] && !isNaN(parseFloat(doc.zoomscale)));
        if (isZoomScaleANumber)
        {
            zoomScale = doc.zoomscale;
        }

        if (doc.symbols[0])
        {
            pictureMarkerSymbolURL = doc.symbols.picturemarkersymbol.@url;
        }
    }

    public function exportXML():XML
    {
        const configXML:XML =
            <configuration>
                <source>{source}</source>
                <fields>
                    <field name={fieldName} alias={fieldAlias}/>
                </fields>
                <titlefield>{titleField}</titlefield>
                <linkfield>{linkField}</linkfield>
                <refreshrate>{refreshRate}</refreshrate>
                <zoomscale>{zoomScale}</zoomscale>
            </configuration>;

        if (useProxy)
        {
            configXML.appendChild(<useproxy>true</useproxy>);
        }

        if (pictureMarkerSymbolURL)
        {
            configXML.appendChild(getPictureMarkerSymbolXML());
        }
        return configXML;
    }

    private function getPictureMarkerSymbolXML():XML
    {
        var symbolXML:XML =
            <symbols>
                <picturemarkersymbol/>
            </symbols>;
        symbolXML.picturemarkersymbol.@url = pictureMarkerSymbolURL;
        return symbolXML;
    }
}
}
