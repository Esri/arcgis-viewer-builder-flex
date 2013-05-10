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

[Bindable]
public class FieldSettings
{
    public var name:String;
    public var alias:String;
    public var tooltip:String;

    public function fromXML(configXML:XML):void
    {
        name = configXML.@name[0];
        alias = configXML.@alias[0];
        tooltip = configXML.@tooltip[0];
    }

    public function toXML():XML
    {
        var configXML:XML = <field name={name}/>

        if (alias)
        {
            configXML.@alias = alias;
        }
        if (tooltip)
        {
            configXML.@tooltip = tooltip;
        }

        return configXML;
    }
}
}
