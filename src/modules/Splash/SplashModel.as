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
package modules.Splash
{

import com.esri.builder.supportClasses.XMLUtil;

import modules.IWidgetModel;

import mx.resources.ResourceManager;

public class SplashModel implements IWidgetModel
{
    [Bindable]
    public var width:Number = 300;
    [Bindable]
    public var height:Number = 300;
    [Bindable]
    public var content:String = "...";
    [Bindable]
    public var buttonLabel:String = ResourceManager.getInstance().getString('BuilderStrings', 'ok');

    public function importXML(doc:XML):void
    {
        //TODO: null check
        width = doc.width;
        height = doc.height;
        content = doc.content;

        var parsedButtonLabel:String = (doc.labels.btnlabel[0] || doc.btnlabel[0]);
        if (parsedButtonLabel)
        {
            buttonLabel = parsedButtonLabel;
        }
    }

    public function exportXML():XML
    {
        var configXML:XML =
            <configuration>
                <width>{width}</width>
                <height>{height}</height>
                <content>{XMLUtil.wrapInCDATA(content)}</content>
                <labels>
                    <btnlabel>{buttonLabel}</btnlabel>
                </labels>
            </configuration>;
        return configXML;
    }
}
}
