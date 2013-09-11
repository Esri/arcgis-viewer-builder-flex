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

import com.esri.builder.model.Model;

import modules.IWidgetModel;

import mx.resources.ResourceManager;

public class HeaderControllerModel implements IWidgetModel
{
    private const DEFAULT_LOCATOR_URL:String = 'http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer';

    [Bindable]
    public var aboutText:String = ResourceManager.getInstance().getString('BuilderStrings', 'headerController.about');
    [Bindable]
    public var isAboutVisible:Boolean = true;
    public var aboutWidth:Number = 300;
    public var aboutHeight:Number = 300;
    [Bindable]
    public var aboutContent:String =
        "<p align='center'><img src='assets/images/globe.png' width='140' height='140' /></p>" +
        "<br>More information at links below:" +
        "<textformat indent=\"25\"><p><br><a href=\"http://links.esri.com/flexviewer\" target='_blank'><font color='#FFFF00'>ArcGIS Viewer for Flex</font></a>" +
        "<br><a href=\"http://links.esri.com/flex\" target='_blank'><font color='#FFFF00'>ArcGIS API for Flex</font></a>" +
        "<br><a href=\"http://www.esri.com\" target='_blank'><font color='#FFFF00'>Esri</font></a></p></textformat>";

    public var aboutCloseButtonLabel:String = ResourceManager.getInstance().getString('BuilderStrings', 'headerController.ok');

    [Bindable]
    public var zoomScale:String = '10000';
    [Bindable]
    public var minScore:Number = 40;
    [Bindable]
    public var prompt:String;
    [Bindable]
    public var searchResultTitle:String;
    [Bindable]
    public var searchResultDescription:String;
    [Bindable]
    public var locatorURL:String = Model.instance.geocodeURL || DEFAULT_LOCATOR_URL;
    [Bindable]
    public var useProxy:Boolean = false;
    [Bindable]
    public var geocoderURL:String;
    [Bindable]
    public var geocoderSuffix:String;
    [Bindable]
    public var geocoderPrefix:String;
    [Bindable]
    public var locatorEnabled:Boolean = true;
    [Bindable]
    public var mapServicesEnabled:Boolean;

    public var mapServices:Array = [];

    public function get isGeocoderVisible():Boolean
    {
        return locatorEnabled || mapServicesEnabled;
    }

    //preserved
    private var autoComplete:XML;
    private var geocoderSymbols:XML;
    private var locatorOptions:XML;
    private var maxLocations:XML;
    private var minChars:XML;
    private var searchDelay:XML;

    public var links:Array = [];

    public function importXML(doc:XML):void
    {
        if (doc.about[0])
        {
            const aboutLink:Link = aboutXMLToLinkXML(doc);
            if (aboutLink)
            {
                links.push(aboutLink);
            }
        }

        if (doc.links[0])
        {
            var link:Link;
            for each (var linkXML:XML in doc.links.link)
            {
                link = Link.fromXML(linkXML);
                if (link)
                {
                    links.push(link);
                }
            }
        }

        var geocoderXML:XML = ensureLatestConfig(doc.search[0] || doc.geocoder[0]);
        if (geocoderXML)
        {
            locatorEnabled = geocoderXML.@visible != "false"
                && geocoderXML.usemapservicesonly[0] != "true";

            const parsedZoomScale:String = geocoderXML.zoomscale[0];
            if (parsedZoomScale)
            {
                zoomScale = parsedZoomScale;
            }

            useProxy = geocoderXML.useproxy[0] == "true";

            if (geocoderXML.labels[0])
            {
                const parsedPrompt:String = geocoderXML.labels.searchprompt[0];
                if (parsedPrompt)
                {
                    prompt = parsedPrompt;
                }

                const parsedSearchResultTitle:String = geocoderXML.result.title[0] || geocoderXML.labels.searchresulttitle[0];
                if (parsedSearchResultTitle)
                {
                    searchResultTitle = parsedSearchResultTitle;
                }

                const parsedSearchResultDescription:String = geocoderXML.result.description[0];
                if (parsedSearchResultDescription)
                {
                    searchResultDescription = parsedSearchResultDescription;
                }
            }

            //TODO: check defaults
            const parsedLocatorURL:String = geocoderXML.url[0];
            if (parsedLocatorURL)
            {
                locatorURL = parsedLocatorURL;
            }
            const parsedMinScore:Number = parseFloat(geocoderXML.minscore[0]);
            if (!isNaN(parsedMinScore))
            {
                minScore = parsedMinScore;
            }

            //preserve for now
            autoComplete = geocoderXML.autocomplete[0];
            minChars = geocoderXML.minchars[0];
            searchDelay = geocoderXML.searchdelay[0];
            maxLocations = geocoderXML.maxlocations[0];
            locatorOptions = geocoderXML.locatoroptions[0];
            geocoderSymbols = geocoderXML.symbols[0];

            if (geocoderXML.mapservices[0])
            {
                mapServicesEnabled = geocoderXML.mapservices.@enabled[0] != "false";
                importMapServices(geocoderXML.mapservices[0]);
            }
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

    private function ensureLatestConfig(configXML:XML):XML
    {
        if (configXML && configXML.name() == "search")
        {
            configXML.setName("geocoder");

            var geocodingXML:XML = configXML.geocoding[0];
            if (geocodingXML)
            {
                var geocoderEnabled:Boolean = geocodingXML.@enabled != "false";
                if (geocoderEnabled)
                {
                    var locatorURL:String = geocodingXML.locator[0];
                    if (locatorURL)
                    {
                        configXML.appendChild(<url>{locatorURL}</url>);
                    }
                }
                else
                {
                    configXML.appendChild(<usemapservicesonly>true</usemapservicesonly>);
                }

                var minScore:Number = parseFloat(geocodingXML.minscore[0]);
                if (!isNaN(minScore))
                {
                    configXML.appendChild(<minscore>{minScore}</minscore>);
                }

                delete configXML.geocoding[0];
            }

            var searchLayersXML:XML = configXML.searchlayers[0];
            if (searchLayersXML)
            {
                searchLayersXML.setName("mapservices");

                for each (var searchLayerXML:XML in searchLayersXML.searchlayer)
                {
                    searchLayerXML.setName("mapservice");
                }
            }
        }

        return configXML;
    }

    private function aboutXMLToLinkXML(configXML:XML):Link
    {
        var aboutLink:Link;

        if (configXML.about.visible[0] != "false")
        {
            aboutLink = new Link();
            aboutLink.content = configXML.about.content || "";
            aboutLink.label = configXML.labels.abouttext[0] || configXML.about.label[0] || ResourceManager.getInstance().getString('BuilderStrings', 'headerController.about');
            aboutLink.contentCloseLabel = configXML.labels.btnlabel[0] || configXML.about.btnlabel[0] || "";
            if (configXML.about.width[0])
            {
                aboutLink.contentWidth = configXML.about.width[0];
            }
            if (configXML.about.height[0])
            {
                aboutLink.contentHeight = configXML.about.height[0];
            }
        }

        return aboutLink;
    }

    public function exportXML():XML
    {
        const configXML:XML = <configuration/>;

        configXML.appendChild(getGeocoderXML());

        if (links.length > 0)
        {
            configXML.appendChild(getLinksXML());
        }

        return configXML;
    }

    private function getGeocoderXML():XML
    {
        var geocoderXML:XML = <geocoder/>;

        geocoderXML.@visible = isGeocoderVisible;

        if (locatorURL)
        {
            geocoderXML.appendChild(<url>{locatorURL}</url>);
        }

        geocoderXML.appendChild(<useproxy>{useProxy}</useproxy>);

        if (zoomScale)
        {
            geocoderXML.appendChild(<zoomscale>{zoomScale}</zoomscale>);
        }

        if (minScore)
        {
            geocoderXML.appendChild(<minscore>{minScore}</minscore>);
        }

        if (autoComplete)
        {
            geocoderXML.appendChild(autoComplete);
        }
        if (geocoderSymbols)
        {
            geocoderXML.appendChild(geocoderSymbols);
        }
        if (locatorOptions)
        {
            geocoderXML.appendChild(locatorOptions);
        }
        if (maxLocations)
        {
            geocoderXML.appendChild(maxLocations);
        }
        if (minChars)
        {
            geocoderXML.appendChild(minChars);
        }
        if (searchDelay)
        {
            geocoderXML.appendChild(searchDelay);
        }
        if (!locatorEnabled)
        {
            geocoderXML.appendChild(<usemapservicesonly>true</usemapservicesonly>);
        }
        if (searchResultTitle || searchResultDescription)
        {
            var resultXML:XML = <result/>;

            if (searchResultTitle)
            {
                resultXML.appendChild(<title>{searchResultTitle}</title>);
            }
            if (searchResultDescription)
            {
                resultXML.appendChild(<description>{searchResultDescription}</description>);
            }

            geocoderXML.appendChild(resultXML);
        }

        var labelsXML:XML = getLabelsXML();
        if (labelsXML)
        {
            geocoderXML.appendChild(labelsXML);
        }

        if (mapServices.length > 0)
        {
            geocoderXML.appendChild(exportMapServicesXML());
        }

        return geocoderXML;
    }

    private function getLabelsXML():XML
    {
        var labelsXML:XML;

        if (prompt || searchResultTitle)
        {
            labelsXML = <labels/>;

            if (prompt)
            {
                labelsXML.appendChild(<searchprompt>{prompt}</searchprompt>);
            }
        }

        return labelsXML;
    }

    private function getLinksXML():Object
    {
        const linksXML:XML = <links/>;

        for each (var link:Link in links)
        {
            linksXML.appendChild(link.toXML());
        }

        return linksXML;
    }
}
}
