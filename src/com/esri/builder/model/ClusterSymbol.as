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

public class ClusterSymbol
{
    //using strings until cluster symbol property edits are supported
    public var alpha:String;
    public var alphas:String;
    public var borderColor:String;
    public var color:String;
    public var colors:String;
    public var flareMaxCount:String;
    public var size:String;
    public var sizes:String;
    public var textColor:String;
    public var textSize:String;
    public var type:String;
    public var weights:String;

    public static function decodeXML(elem:XML):ClusterSymbol
    {
        const clusterSymbol:ClusterSymbol = new ClusterSymbol();
        clusterSymbol.alpha = elem.@alpha;
        clusterSymbol.alphas = elem.@alphas;
        clusterSymbol.borderColor = elem.@bordercolor;
        clusterSymbol.color = elem.@color;
        clusterSymbol.colors = elem.@colors;
        clusterSymbol.flareMaxCount = elem.@flaremaxcount;
        clusterSymbol.size = elem.@size;
        clusterSymbol.sizes = elem.@sizes;
        clusterSymbol.textColor = elem.@textcolor;
        clusterSymbol.textSize = elem.@textsize;
        clusterSymbol.type = elem.@type;
        clusterSymbol.weights = elem.@weights;

        return clusterSymbol;
    }

    public function encodeXML():XML
    {
        const clusterSymbolXML:XML = <clustersymbol type={type}/>;

        if (alpha)
        {
            clusterSymbolXML.@alpha = alpha;
        }
        if (alphas)
        {
            clusterSymbolXML.@alphas = alphas;
        }
        if (borderColor)
        {
            clusterSymbolXML.@bordercolor = borderColor;
        }
        if (color)
        {
            clusterSymbolXML.@color = color;
        }
        if (colors)
        {
            clusterSymbolXML.@colors = colors;
        }
        if (flareMaxCount)
        {
            clusterSymbolXML.@flaremaxcount = flareMaxCount;
        }
        if (size)
        {
            clusterSymbolXML.@size = size;
        }
        if (sizes)
        {
            clusterSymbolXML.@sizes = sizes;
        }
        if (textColor)
        {
            clusterSymbolXML.@textcolor = textColor;
        }
        if (textSize)
        {
            clusterSymbolXML.@textsize = textSize;
        }
        if (weights)
        {
            clusterSymbolXML.@weights = weights;
        }

        return clusterSymbolXML;
    }
}
}
