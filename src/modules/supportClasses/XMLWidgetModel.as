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
package modules.supportClasses
{

import modules.IWidgetModel;

public final class XMLWidgetModel implements IWidgetModel
{
    [Bindable]
    public var configXML:String = "";

    public function importXML(doc:XML):void
    {
        configXML = ensureFriendlyEmptyConfigXML(doc.toXMLString());
    }

    private function ensureFriendlyEmptyConfigXML(xmlText:String):String
    {
        return (xmlText == "<configuration/>") ? "<configuration></configuration>" : xmlText;
    }

    public function exportXML():XML
    {
        return new XML(configXML);
    }
}
}
