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

public class Clustering
{
    public var minGraphicCount:int;
    public var sizeInPixels:int;
    public var clusterSymbol:ClusterSymbol;

    public static function decodeXML(elem:XML):Clustering
    {
        var cluster:Clustering = new Clustering();
        cluster.minGraphicCount = elem.@mingraphiccount;
        cluster.sizeInPixels = elem.@sizeinpixels;
        cluster.clusterSymbol = ClusterSymbol.decodeXML(elem.clustersymbol[0]);
        return cluster;
    }

    public function encodeXML():XML
    {
        var clusterXML:XML = <clustering/>;
        clusterXML.appendChild(clusterSymbol.encodeXML());
        if (minGraphicCount)
        {
            clusterXML.@mingraphiccount = minGraphicCount;
        }
        if (sizeInPixels)
        {
            clusterXML.@sizeinpixels = sizeInPixels;
        }
        return clusterXML;
    }
}
}
