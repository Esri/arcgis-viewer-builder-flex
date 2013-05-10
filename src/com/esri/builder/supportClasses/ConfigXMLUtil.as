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
package com.esri.builder.supportClasses
{

public class ConfigXMLUtil
{
    public static function mergeChild(parent:XML, childName:String = "", newChild:XML = null, handleAttributes:Boolean = false):void
    {
        if (parent.hasOwnProperty(childName) && newChild == null)
        {
            delete parent.child(childName)[0];
            return;
        }

        if (!parent.hasOwnProperty(childName) && newChild == null)
        {
            return;
        }

        if (childName != newChild.name().localName)
        {
            throw new Error("The given childName and the given newChild XML does not match.");
        }

        if (!parent.hasOwnProperty(childName))
        {
            parent.appendChild(newChild);
            return;
        }

        if (!handleAttributes)
        {
            parent.replace(childName, newChild);
        }
    }
}
}
