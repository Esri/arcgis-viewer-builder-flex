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
package com.esri.builder.controllers
{

import com.esri.builder.controllers.supportClasses.LocalConnectionDelegate;
import com.esri.builder.eventbus.AppEvent;

public final class TitlesController
{
    public var localConnectionDelegate:LocalConnectionDelegate;

    public function TitlesController()
    {
        AppEvent.addListener(AppEvent.TITLES_EXECUTE, onTitlesExecute, false, 0, true);
    }

    private function onTitlesExecute(event:AppEvent):void
    {
        titlesExecute(event.data.title as String, event.data.subTitle as String);
    }

    private function titlesExecute(title:String, subtitle:String):void
    {
        localConnectionDelegate.setTitles(title, subtitle);
    }
}
}
