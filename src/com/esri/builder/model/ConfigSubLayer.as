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

public final class ConfigSubLayer
{
    public var id:String;

    public var popupConfig:String;

    public var definitionExpression:String;

    public function ConfigSubLayer()
    {
    }

    public static function decodeXML(elem:XML):ConfigSubLayer
    {
        const configSubLayer:ConfigSubLayer = new ConfigSubLayer();
        configSubLayer.id = elem.@id;
        configSubLayer.popupConfig = elem.@popupconfig;
        configSubLayer.definitionExpression = elem.@definitionexpression;
        return configSubLayer;
    }

    public function encodeXML():XML
    {
        const subLayerXML:XML = <sublayer id={id}/>;
        if (popupConfig)
        {
            subLayerXML.@popupconfig = popupConfig;
        }
        if (definitionExpression)
        {
            subLayerXML.@definitionexpression = definitionExpression;
        }
        return subLayerXML;
    }
}

}
