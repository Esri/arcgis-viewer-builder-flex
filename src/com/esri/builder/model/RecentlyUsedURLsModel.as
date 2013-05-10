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

import flash.events.Event;
import flash.events.EventDispatcher;

public class RecentlyUsedURLsModel extends EventDispatcher
{
    public static const SHARED_OBJECT_NAME:String = "recentlyUsedURLs";

    private const MAX_URLS_TO_STORE:int = 50;

    private var _urls:Array = [];

    [Bindable("urlsChanged")]
    public function get urls():Array
    {
        return _urls.concat();
    }

    public function loadURLs(value:Array):void
    {
        _urls = value;
        dispatchEvent(new Event("urlsChanged"));
    }

    public function addURL(url:String):void
    {
        if (isURLUnique(url))
        {
            addURLAndEnforceMaxLength(url);
        }
        else
        {
            promoteURLToRecentUsed(url);
        }
    }

    private function isURLUnique(url:String):Boolean
    {
        return _urls.indexOf(url) == -1;
    }

    private function addURLAndEnforceMaxLength(url:String):void
    {
        _urls.unshift(url);
        if (_urls.length > MAX_URLS_TO_STORE)
        {
            _urls.pop();
        }
        dispatchEvent(new Event("urlsChanged"));
    }

    private function promoteURLToRecentUsed(url:String):void
    {
        var urlIndex:int = _urls.indexOf(url);
        var url:String = _urls[urlIndex];
        _urls.splice(urlIndex, 1);
        _urls.unshift(url);
        dispatchEvent(new Event("urlsChanged"));
    }

    public function mostRecentURL():String
    {
        return _urls ? _urls[0] : null;
    }

    //SINGLETON
    private static var instance:RecentlyUsedURLsModel;

    public function RecentlyUsedURLsModel(singletonEnforcer:SingletonEnforcer)
    {
        if (!singletonEnforcer)
        {
            throw new Error("Class should not be instantiated - use getInstance()");
        }
    }

    public static function getInstance():RecentlyUsedURLsModel
    {
        if (!instance)
        {
            instance = new RecentlyUsedURLsModel(new SingletonEnforcer());
        }

        return instance;
    }
}
}

class SingletonEnforcer
{
}
