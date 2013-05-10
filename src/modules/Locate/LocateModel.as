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
package modules.Locate
{

import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.URLUtil;

import modules.IWidgetModel;

[Bindable]
internal final class LocateModel implements IWidgetModel
{
    private const DEF_LOCATOR:String = 'http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer';
    private const DEF_MIN_SCRORE:Number = 40;
    private const DEF_ZOOM_SCALE:String = '10000';

    private var _locator:String = Model.instance.geocodeURL || DEF_LOCATOR;

    public function get locator():String
    {
        return _locator;
    }

    public function set locator(value:String):void
    {
        _locator = URLUtil.encode(value);
    }

    public var useSearchExtent:Boolean = true;
    public var minScore:Number = DEF_MIN_SCRORE;
    public var zoomScale:String = DEF_ZOOM_SCALE;
    public var useProxy:Boolean;

    public function importXML(doc:XML):void
    {
        if (doc.locator[0])
        {
            locator = doc.locator;
        }
        useSearchExtent = (doc.usesearchextent[0] != 'false');
        minScore = doc.minscore || DEF_MIN_SCRORE;
        zoomScale = doc.zoomscale || DEF_ZOOM_SCALE;
        useProxy = doc.useproxy == 'true';
    }

    public function exportXML():XML
    {
        const configXML:XML =
            <configuration>
                <locator>{locator}</locator>
                <usesearchextent>{useSearchExtent}</usesearchextent>
                <minscore>{minScore}</minscore>
                <zoomscale>{zoomScale}</zoomscale>
            </configuration>;

        if (useProxy)
        {
            configXML.appendChild(<useproxy>true</useproxy>);
        }

        return configXML;
    }
}
}
