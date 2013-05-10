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
package modules.StaticImage
{

import modules.IWidgetModel;

public class StaticImageModel implements IWidgetModel
{
    [Bindable]
    public var imageURL:String = "";
    [Bindable]
    public var linkURL:String = "";
    [Bindable]
    public var toolTip:String = "";

    public function importXML(doc:XML):void
    {
        //TODO: null check
        imageURL = doc.imageurl[0];
        linkURL = doc.linkurl[0];
        toolTip = doc.tooltip[0];
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <imageurl>{imageURL}</imageurl>
                <linkurl>{linkURL}</linkurl>
                <tooltip>{toolTip}</tooltip>
            </configuration>;
        return configXML;
    }
}
}
