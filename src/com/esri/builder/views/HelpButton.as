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
    [Bindable]
    public var contentWidth:Number = 220;

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
        helpPopUp.width = contentWidth;
        helpPopUp.title = title;
        helpPopUp.content = helpText;
        return helpPopUp;
    }

    private function positionHelpPopUp(button:UIComponent, popUp:UIComponent):void
    {
        var app:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
        var appBounds:Rectangle = app.getVisibleRect();
        var buttonRect:Rectangle = button.getBounds(app);
        var popUpRect:Rectangle = new Rectangle(buttonRect.x, buttonRect.y, popUp.width, popUp.height);

        var isLTR:Boolean = (layoutDirection == LayoutDirection.LTR);
        var anchorWidth:Number = helpPopUp.anchor.width;
        var leftOffset:Number = isLTR ? -popUpRect.width - anchorWidth : buttonRect.width + anchorWidth;
        var rightOffset:Number = isLTR ? buttonRect.width + anchorWidth : -popUpRect.width - anchorWidth;

        var leftPopUpRect:Rectangle = popUpRect.clone();
        var rightPopUpRect:Rectangle = popUpRect.clone();
        var bottomPopUpRect:Rectangle = popUpRect.clone();
        var topPopUpRect:Rectangle = popUpRect.clone();

        leftPopUpRect.x += leftOffset;
        rightPopUpRect.x += rightOffset;
        bottomPopUpRect.y += buttonRect.height;
        topPopUpRect.y += -popUpRect.height;

        var leftIntersectionRect:Rectangle = appBounds.intersection(leftPopUpRect);
        var rightIntersectionRect:Rectangle = appBounds.intersection(rightPopUpRect);
        var bottomIntersectionRect:Rectangle = appBounds.intersection(bottomPopUpRect);
        var topIntersectionRect:Rectangle = appBounds.intersection(topPopUpRect);

        var horizontalPosition:String;

        if (isLTR)
        {
            if (leftIntersectionRect.width > rightIntersectionRect.width)
            {
                popUp.x = leftPopUpRect.x;
                horizontalPosition = "LEFT";
            }
            else
            {
                popUp.x = rightPopUpRect.x;
                horizontalPosition = "RIGHT";
            }
        }
        else
        {
            if (leftIntersectionRect.width < rightIntersectionRect.width)
            {
                popUp.x = app.width - rightPopUpRect.x - rightPopUpRect.width;
                horizontalPosition = "LEFT";
            }
            else
            {
                popUp.x = app.width - leftPopUpRect.x - leftPopUpRect.width;
                horizontalPosition = "RIGHT";
            }
        }

        var verticalPosition:String;

        if (Math.round(topIntersectionRect.height) > Math.round(bottomIntersectionRect.height))
        {
            popUp.y = topPopUpRect.y;
            verticalPosition = "TOP";
        }
        else if (Math.round(topIntersectionRect.height) < Math.round(bottomIntersectionRect.height))
        {
            popUp.y = bottomPopUpRect.y;
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

    private function positionHelpPopUpAnchor(popUpPosition:String):void
    {
        var anchorWidth:Number = helpPopUp.anchor.width;
        //we assume help pop-up anchor points to the right: <
        switch (popUpPosition)
        {
            case "MIDDLE_RIGHT":
            {
                helpPopUp.anchor.left = -anchorWidth;
                helpPopUp.anchor.verticalCenter = 0;
                break;
            }
            case "MIDDLE_LEFT":
            {
                helpPopUp.anchor.right = -anchorWidth;
                helpPopUp.anchor.rotation = 180;
                helpPopUp.anchor.verticalCenter = 0;
                break;
            }
            case "TOP_RIGHT":
            {
                helpPopUp.anchor.left = -anchorWidth;
                helpPopUp.anchor.bottom = -anchorWidth;
                helpPopUp.anchor.scaleX = 2.5;
                helpPopUp.anchor.rotation = -45;
                break;
            }
            case "TOP_LEFT":
            {
                helpPopUp.anchor.right = -anchorWidth;
                helpPopUp.anchor.bottom = -anchorWidth;
                helpPopUp.anchor.scaleX = 2.5;
                helpPopUp.anchor.rotation = -135;
                break;
            }
            case "BOTTOM_RIGHT":
            {
                helpPopUp.anchor.top = -anchorWidth;
                helpPopUp.anchor.left = -anchorWidth;
                helpPopUp.anchor.scaleX = 2.5;
                helpPopUp.anchor.rotation = 45;
                break;
            }
            case "BOTTOM_LEFT":
            {
                helpPopUp.anchor.top = -anchorWidth;
                helpPopUp.anchor.right = -anchorWidth;
                helpPopUp.anchor.scaleX = 2.5;
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
