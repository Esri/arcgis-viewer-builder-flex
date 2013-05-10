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
package modules.Directions
{

import com.esri.builder.model.Model;
import com.esri.builder.model.WidgetContainer;

import modules.HeaderController.MapService;
import modules.IWidgetModel;

public class DirectionsModel implements IWidgetModel
{
    private const DEFAULT_DIRECTIONS_URL:String = 'http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World';
    private const DEFAULT_LOCATOR_URL:String = 'http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer';

    [Bindable]
    public var isOpenOnStartUp:Boolean = false;
    [Bindable]
    public var routeURL:String = Model.instance.directionsURL || DEFAULT_DIRECTIONS_URL;
    [Bindable]
    public var routeUseProxy:Boolean = false;
    [Bindable]
    public var locatorURL:String = Model.instance.geocodeURL || DEFAULT_LOCATOR_URL;
    [Bindable]
    public var locatorUseProxy:Boolean = false;
    [Bindable]
    public var locatorEnabled:Boolean = true;
    [Bindable]
    public var mapServicesEnabled:Boolean;

    public var mapServices:Array = [];

    //preserved
    private var autoComplete:XML;
    private var geocoderSymbols:XML;
    private var locatorOptions:XML;
    private var maxLocations:XML;
    private var minChars:XML;
    private var minScore:XML;
    private var searchDelay:XML;
    private var directionsLanguage:XML;
    private var directionsLengthUnits:XML;
    private var directionsOutputType:XML;

    public function DirectionsModel()
    {
        for each (var widgetContainer:WidgetContainer in Model.instance.config.widgetContainerArray)
        {
            if (widgetContainer.panelType == "left")
            {
                isOpenOnStartUp = widgetContainer.initialState == "open" ? true : false;
                break;
            }
        }
    }

    public function importXML(doc:XML):void
    {
        const parsedRouteURL:String = doc.url[0];
        if (parsedRouteURL)
        {
            routeURL = parsedRouteURL;
        }

        const parsedLocatorURL:String = doc.locatorurl[0];
        if (parsedLocatorURL)
        {
            locatorURL = parsedLocatorURL;
        }

        routeUseProxy = doc.useproxy[0] == "true";
        locatorUseProxy = doc.useproxyforlocator[0] == "true";

        var geocoderOptionsXML:XML = doc.geocoderoptions[0];
        if (geocoderOptionsXML)
        {
            locatorEnabled = geocoderOptionsXML.usemapservicesonly[0] != "true";

            //preserve for now            
            autoComplete = geocoderOptionsXML.autocomplete[0];
            minChars = geocoderOptionsXML.minchars[0];
            searchDelay = geocoderOptionsXML.searchdelay[0];
            maxLocations = geocoderOptionsXML.maxlocations[0];
            minScore = geocoderOptionsXML.minscore[0];
            locatorOptions = geocoderOptionsXML.locatoroptions[0];

            if (geocoderOptionsXML.mapservices[0])
            {
                mapServicesEnabled = geocoderOptionsXML.mapservices.@enabled[0] != "false";
                importMapServices(geocoderOptionsXML.mapservices[0]);
            }
        }

        if (!locatorEnabled && !mapServicesEnabled)
        {
            locatorEnabled = true;
        }

        var routeOptionsXML:XML = doc.routeOptions[0];
        if (routeOptionsXML)
        {
            routeOptionsXML = doc.routeOptionsXML;

            directionsLanguage = routeOptionsXML.directionslanguage[0];
            directionsLengthUnits = routeOptionsXML.directionslengthunits[0];
            directionsOutputType = routeOptionsXML.directionsoutputtype[0];
        }
    }

    private function importMapServices(mapServicesXML:XML):void
    {
        var mapService:MapService;
        for each (var mapServiceXML:XML in mapServicesXML.mapservice)
        {
            var hasRequiredProperties:Boolean = mapServiceXML.url[0] && mapServiceXML.layerids[0];
            if (hasRequiredProperties)
            {
                mapService = new MapService();
                mapService.url = mapServiceXML.url[0];
                mapService.layerIds.source = mapServiceXML.layerids[0].split(",");
                mapService.name = mapServiceXML.name[0];
                mapService.proxyURL = mapServiceXML.proxyurl[0];
                mapService.useProxy = mapServiceXML.useproxy[0] == "true";
                if (mapServiceXML.searchfields[0])
                {
                    mapService.searchFields.source = mapServiceXML.searchfields[0].split(",");
                }
                mapServices.push(mapService);
            }
        }
    }

    private function exportMapServicesXML():XML
    {
        var mapServicesXML:XML = <mapservices enabled={mapServicesEnabled}/>;

        for each (var mapService:MapService in mapServices)
        {
            mapServicesXML.appendChild(mapService.toXML());
        }

        return mapServicesXML;
    }

    public function exportXML():XML
    {
        var configXML:XML = <configuration/>;

        if (routeURL)
        {
            configXML.appendChild(<url>{routeURL}</url>);
        }
        configXML.appendChild(<useproxy>{routeUseProxy}</useproxy>);

        if (locatorURL)
        {
            configXML.appendChild(<locatorurl>{locatorURL}</locatorurl>);
        }
        configXML.appendChild(<useproxyforlocator>{locatorUseProxy}</useproxyforlocator>);

        configXML.appendChild(getGeocoderOptionsXML());
        configXML.appendChild(getRouteOptionsXML());

        return configXML;
    }

    private function getGeocoderOptionsXML():XML
    {
        var geocoderOptionsXML:XML = <geocoderoptions/>;

        if (autoComplete)
        {
            geocoderOptionsXML.appendChild(autoComplete);
        }
        if (locatorOptions)
        {
            geocoderOptionsXML.appendChild(locatorOptions);
        }
        if (maxLocations)
        {
            geocoderOptionsXML.appendChild(maxLocations);
        }
        if (minChars)
        {
            geocoderOptionsXML.appendChild(minChars);
        }
        if (minScore)
        {
            geocoderOptionsXML.appendChild(minScore);
        }
        if (searchDelay)
        {
            geocoderOptionsXML.appendChild(searchDelay);
        }
        if (!locatorEnabled)
        {
            geocoderOptionsXML.appendChild(<usemapservicesonly>true</usemapservicesonly>);
        }

        if (mapServices.length > 0)
        {
            geocoderOptionsXML.appendChild(exportMapServicesXML());
        }

        return geocoderOptionsXML;
    }

    private function getRouteOptionsXML():XML
    {
        var routeOptionsXML:XML = <routeoptions/>;

        if (directionsLanguage)
        {
            routeOptionsXML.appendChild(directionsLanguage);
        }
        if (directionsLengthUnits)
        {
            routeOptionsXML.appendChild(directionsLengthUnits);
        }
        if (directionsOutputType)
        {
            routeOptionsXML.appendChild(directionsOutputType);
        }

        return routeOptionsXML;
    }
}

}
