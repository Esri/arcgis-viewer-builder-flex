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
package com.esri.builder.components.serviceBrowser.nodes
{

import com.esri.builder.supportClasses.URLUtil;

import mx.utils.StringUtil;

public class ServerNode extends ServiceDirectoryNode
{
    private var _type:String;

    public function get type():String
    {
        return _type;
    }

    public function get shorthandType():String
    {
        return ""; //subclasses must implement
    }

    override public function get displayLabel():String
    {
        return StringUtil.substitute("{0} \u202A({1})\u202C",
                                     super.displayLabel, shorthandType);
    }

    public function ServerNode(parent:ServiceDirectoryNode, name:String, type:String)
    {
        const parentDirectory:String = parent.name + "/";
        //need to encode name here since parent directory name is already encoded
        super(parent, URLUtil.encode(name).replace(parentDirectory, ''));
        _type = type;
    }

    private var _path:String;

    override public function get path():String
    {
        //cache
        return _path ||= buildPath();
    }

    private function buildPath():String
    {
        return StringUtil.substitute("{0}/{1}",
                                     name,
                                     type);
    }

    override public function get url():String
    {
        return parent.url + '/' + path;
    }

    private var _isBranch:Boolean;

    override public function get isBranch():Boolean
    {
        return _isBranch;
    }

    public function set isBranch(value:Boolean):void
    {
        _isBranch = value;
    }
}
}
