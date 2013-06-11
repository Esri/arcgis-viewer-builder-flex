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
import flash.geom.Rectangle;

import mx.core.FlexGlobals;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.managers.PopUpManager;

import spark.components.supportClasses.ButtonBase;

[Exclude(kind="property", name="toolTip")]
public class HelpButton extends ButtonBase
{
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
            positionHelpPopUp(this, helpPopUp);
        }
    }

    private function createHelpPopUp():HelpPopUp
    {
        helpPopUp = new HelpPopUp();
        helpPopUp.title = title;
        helpPopUp.content = helpText;
        helpPopUp.x = x;
        helpPopUp.y = y;
        return helpPopUp;
    }

    private function positionHelpPopUp(button:UIComponent, popUp:UIComponent):void
    {
        var app:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
        var appBounds:Rectangle = app.getVisibleRect(this);
        var buttonRect:Rectangle = button.getVisibleRect(this);
        var popUpRect:Rectangle = popUp.getVisibleRect(this);

        var isLTR:Boolean = (layoutDirection == LayoutDirection.LTR);
        var leftOffset:Number = isLTR ? -popUpRect.width - anchorHalfWidth : anchorHalfWidth;
        var rightOffset:Number = isLTR ? buttonRect.width + anchorHalfWidth : -buttonRect.width - popUpRect.width - anchorHalfWidth;

        var leftPopUpRect:Rectangle = popUpRect.clone();
        var rightPopUpRect:Rectangle = popUpRect.clone();
        var bottomPopUpRect:Rectangle = popUpRect.clone();
        var topPopUpRect:Rectangle = popUpRect.clone();

        leftPopUpRect.x = buttonRect.x + leftOffset;
        rightPopUpRect.x = buttonRect.x + rightOffset;
        bottomPopUpRect.y = buttonRect.y + buttonRect.height;
        topPopUpRect.y = buttonRect.y - popUpRect.height;

        var leftIntersectionRect:Rectangle = appBounds.intersection(leftPopUpRect);
        var rightIntersectionRect:Rectangle = appBounds.intersection(rightPopUpRect);
        var bottomIntersectionRect:Rectangle = appBounds.intersection(bottomPopUpRect);
        var topIntersectionRect:Rectangle = appBounds.intersection(topPopUpRect);

        var horizontalPosition:String;

        if (leftIntersectionRect.width > rightIntersectionRect.width)
        {
            popUp.x = buttonRect.x + leftOffset;
            horizontalPosition = "LEFT";
        }
        else
        {
            popUp.x = buttonRect.x + rightOffset;
            horizontalPosition = "RIGHT";
        }

        var verticalPosition:String;

        if (Math.round(topIntersectionRect.height) > Math.round(bottomIntersectionRect.height))
        {
            popUp.y = buttonRect.y - popUpRect.height;
            verticalPosition = "TOP";
        }
        else if (Math.round(topIntersectionRect.height) < Math.round(bottomIntersectionRect.height))
        {
            popUp.y = buttonRect.y + buttonRect.height;
            verticalPosition = "BOTTOM";
        }
        else
        {
            popUp.y = buttonRect.y + (buttonRect.height - popUpRect.height) * 0.5;
            verticalPosition = "MIDDLE";
        }

        var popUpPosition:String = verticalPosition + "_" + horizontalPosition;
        positionHelpPopUpAnchor(popUpPosition);
    }

    public function get anchorHalfWidth():Number
    {
        return helpPopUp.anchor.width * 0.5;
    }

    private function positionHelpPopUpAnchor(popUpPosition:String):void
    {
        //we assume help pop-up anchor points to the right: <
        switch (popUpPosition)
        {
            case "MIDDLE_RIGHT":
            {
                helpPopUp.anchor.left = -anchorHalfWidth;
                helpPopUp.anchor.verticalCenter = 0;
                break;
            }
            case "MIDDLE_LEFT":
            {
                helpPopUp.anchor.right = -anchorHalfWidth;
                helpPopUp.anchor.rotation = 180;
                helpPopUp.anchor.verticalCenter = 0;
                break;
            }
            case "TOP_RIGHT":
            {
                helpPopUp.anchor.left = -anchorHalfWidth;
                helpPopUp.anchor.bottom = -anchorHalfWidth;
                helpPopUp.anchor.scaleX = 2;
                helpPopUp.anchor.rotation = -45;
                break;
            }
            case "TOP_LEFT":
            {
                helpPopUp.anchor.right = -anchorHalfWidth;
                helpPopUp.anchor.bottom = -anchorHalfWidth;
                helpPopUp.anchor.scaleX = 2;
                helpPopUp.anchor.rotation = -135;
                break;
            }
            case "BOTTOM_RIGHT":
            {
                helpPopUp.anchor.top = -anchorHalfWidth;
                helpPopUp.anchor.left = -anchorHalfWidth;
                helpPopUp.anchor.scaleX = 2;
                helpPopUp.anchor.rotation = 45;
                break;
            }
            case "BOTTOM_LEFT":
            {
                helpPopUp.anchor.top = -anchorHalfWidth;
                helpPopUp.anchor.right = -anchorHalfWidth;
                helpPopUp.anchor.scaleX = 2;
                helpPopUp.anchor.rotation = 135;
                break;
            }
        }
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
