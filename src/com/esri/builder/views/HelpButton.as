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
package com.esri.builder.views
{

import com.esri.builder.views.popups.HelpPopUp;

import flash.events.MouseEvent;
import flash.geom.Point;

import mx.managers.PopUpManager;

import spark.components.supportClasses.ButtonBase;

[Exclude(kind="property", name="toolTip")]
public class HelpButton extends ButtonBase
{
    private const ANCHOR_OFFSET:Number = 4;

    [Bindable]
    public var title:String;
    [Bindable]
    public var helpText:String;

    private var helpPopUp:HelpPopUp;

    public function HelpButton()
    {
        addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, false, 0, true);
        addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, false, 0, true);
    }

    protected function rollOverHandler(event:MouseEvent):void
    {
        if (!helpPopUp)
        {
            helpPopUp = createHelpPopUp();
            PopUpManager.addPopUp(helpPopUp, this);
        }
    }

    private function createHelpPopUp():HelpPopUp
    {
        helpPopUp = new HelpPopUp();
        positionHelpPopUp();
        helpPopUp.title = title;
        helpPopUp.content = helpText;
        return helpPopUp;
    }

    private function positionHelpPopUp():void
    {
        //TODO: is there better way to do this?
        var helpButtonX:Number = width;
        if (layoutDirection == 'rtl')
        {
            helpButtonX += helpPopUp.width;
        }
        var helpButtonPoint:Point = new Point(helpButtonX, -ANCHOR_OFFSET);
        var globalPopUpPoint:Point = localToGlobal(helpButtonPoint);
        helpPopUp.x = globalPopUpPoint.x;
        helpPopUp.y = globalPopUpPoint.y;
    }

    protected function rollOutHandler(event:MouseEvent):void
    {
        if (helpPopUp)
        {
            PopUpManager.removePopUp(helpPopUp);
            helpPopUp = null;
        }
    }
}
}
