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

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import spark.components.SkinnablePopUpContainer;
import spark.components.supportClasses.ButtonBase;

[SkinState("normal")]
[SkinState("normalYesNo")]
[SkinState("closed")]
public final class BuilderAlert extends SkinnablePopUpContainer
{
    [SkinPart]
    [Bindable]
    public var title:String;

    [SkinPart]
    [Bindable]
    public var text:String;

    [SkinPart]
    public var yesButton:ButtonBase;

    [SkinPart]
    public var noButton:ButtonBase;

    [SkinPart]
    public var okButton:ButtonBase;

    public var flags:int = Alert.OK;

    public var handler:Function;

    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance === yesButton)
        {
            yesButton.addEventListener(MouseEvent.CLICK, yesButton_clickHandler);
            return;
        }
        if (instance === noButton)
        {
            noButton.addEventListener(MouseEvent.CLICK, noButton_clickHandler);
            return;
        }
        if (instance === okButton)
        {
            okButton.addEventListener(MouseEvent.CLICK, okButton_clickHandler);
            return;
        }
    }

    private function okButton_clickHandler(event:MouseEvent):void
    {
        close();
        if (handler !== null)
        {
            handler(new CloseEvent(CloseEvent.CLOSE, true, true, Alert.OK));
        }
    }

    private function noButton_clickHandler(event:MouseEvent):void
    {
        close();
        if (handler !== null)
        {
            handler(new CloseEvent(CloseEvent.CLOSE, true, true, Alert.NO));
        }
    }

    private function yesButton_clickHandler(event:MouseEvent):void
    {
        close();
        if (handler !== null)
        {
            handler(new CloseEvent(CloseEvent.CLOSE, true, true, Alert.YES));
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        if (instance === yesButton)
        {
            yesButton.removeEventListener(MouseEvent.CLICK, yesButton_clickHandler);
            return;
        }
        if (instance === noButton)
        {
            noButton.removeEventListener(MouseEvent.CLICK, noButton_clickHandler);
            return;
        }
        if (instance === okButton)
        {
            okButton.removeEventListener(MouseEvent.CLICK, okButton_clickHandler);
        }
    }

    override protected function getCurrentSkinState():String
    {
        const currState:String = super.getCurrentSkinState();
        if (currState === 'normal' && flags === (Alert.YES | Alert.NO))
        {
            return 'normalYesNo';
        }
        return currState;
    }

    public static function show(
        text:String = '',
        title:String = '',
        flags:int = Alert.OK,
        parent:DisplayObject = null,
        handler:Function = null,
        icon:Object = null,
        defaultFlag:int = Alert.OK
        ):void
    {

        const alert:BuilderAlert = new BuilderAlert();
        alert.text = text;
        alert.title = title;
        alert.flags = flags;
        alert.handler = handler;
        alert.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    override public function updatePopUpPosition():void
    {
        PopUpManager.centerPopUp(this);
    }
}
}
