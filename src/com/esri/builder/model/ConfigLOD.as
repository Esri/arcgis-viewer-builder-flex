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

public final class ConfigLOD
{
    public var resolution:Number;

    public var scale:Number;

    public function ConfigLOD()
    {
    }

    public function encodeXML():XML
    {
        return <lod resolution={resolution} scale={scale}/>;
    }

    public static function decodeXML(elem:XML):ConfigLOD
    {
        const lod:ConfigLOD = new ConfigLOD();
        lod.resolution = elem.@resolution;
        lod.scale = elem.@scale;
        return lod;
    }
}
}
