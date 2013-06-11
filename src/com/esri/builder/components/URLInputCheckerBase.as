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
package com.esri.builder.components
{

import com.esri.builder.supportClasses.URLUtil;

import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import spark.components.TextInput;
import spark.events.TextOperationEvent;

[Exclude(kind="property", name="text")]

[SkinState("busy")]
[SkinState("valid")]
[SkinState("invalid")]

[Event(name="validURL", type="flash.events.Event")]
[Event(name="invalidURL", type="flash.events.Event")]
[Event(name="busy", type="flash.events.Event")]

public class URLInputCheckerBase extends TextInput
{
    private const DEFAULT_VALIDATION_DELAY_IN_SEC:Number = 0.8;
    private const DEFAULT_REQUEST_TIMEOUT_IN_SEC:Number = 5;

    private var validationTimer:Timer;

    private var urlChanged:Boolean;
    private var proxyURLChanged:Boolean;
    private var validationDelayChanged:Boolean;
    private var isURLValidationPending:Boolean;

    protected var requestTimeoutChanged:Boolean;
    protected var url:String;

    public var responseValidationFunction:Function;
    public var toValidationURLFunction:Function;

    private var _isURLValid:Boolean;

    [Bindable(event="isURLValidChanged")]
    public function get isURLValid():Boolean
    {
        return _isURLValid;
    }

    [Bindable("change")]
    [Bindable("textChanged")]
    [CollapseWhiteSpace]
    override public function set text(value:String):void
    {
        if (text != value)
        {
            urlChanged = true;
            setTextInternally(value);
            invalidateProperties();
        }
    }

    protected function setTextInternally(value:String):void
    {
        super.text = value;
        dispatchEvent(new Event("textChanged"));
    }

    private var _proxyURL:String;

    [Bindable]
    public function get proxyURL():String
    {
        return _proxyURL;
    }

    public function set proxyURL(value:String):void
    {
        if (_proxyURL != value)
        {
            _proxyURL = value;
            proxyURLChanged = true;
            invalidateProperties();
        }
    }

    private var _requestTimeout:Number = DEFAULT_REQUEST_TIMEOUT_IN_SEC;

    [Bindable]
    public function get requestTimeout():Number
    {
        return _requestTimeout;
    }

    public function set requestTimeout(value:Number):void
    {
        if (_requestTimeout != value)
        {
            _requestTimeout = value;
            requestTimeoutChanged = true;
            invalidateProperties();
        }
    }

    private var _validationDelay:Number = DEFAULT_VALIDATION_DELAY_IN_SEC;

    [Bindable]
    public function get validationDelay():Number
    {
        return _validationDelay;
    }

    public function set validationDelay(value:Number):void
    {
        if (_validationDelay != value
            && value >= 0)
        {
            _validationDelay = value;
            validationDelayChanged = true;
            invalidateProperties();
        }
    }

    override protected function commitProperties():void
    {
        if (validationDelayChanged)
        {
            validationTimer.delay = toMillis(validationDelay);
            validationDelayChanged = false;
        }

        if (urlChanged)
        {
            setURL(text);
            requestURLValidation();
            urlChanged = false;
        }

        if (proxyURLChanged)
        {
            requestURLValidation();
            proxyURLChanged = false;
        }

        if (requestTimeoutChanged)
        {
            requestTimeoutChanged = false;
        }

        super.commitProperties();
    }

    private function setURL(text:String):void
    {
        url = (toValidationURLFunction != null) ? toValidationURLFunction(text) : text;
    }

    private function toMillis(seconds:Number):Number
    {
        return seconds * 1000;
    }

    protected function requestURLValidation():void
    {
        if (enabled)
        {
            isURLValidationPending = true;
            validationTimer.reset();
            validationTimer.start();
            dispatchEvent(new Event("busy"));
            invalidateSkinState();
        }
    }

    override protected function createChildren():void
    {
        addEventListener(TextOperationEvent.CHANGE, this_changeHandler);
        initURLChecker();
        initValidationTimer();
        super.createChildren();
    }

    protected function initURLChecker():void
    {
        //subclasses must implement
    }

    private function this_changeHandler(event:TextOperationEvent):void
    {
        urlChanged = true;
        invalidateProperties();
    }

    private function initValidationTimer():void
    {
        validationTimer = new Timer(toMillis(validationDelay), 1);
        validationTimer.addEventListener(TimerEvent.TIMER_COMPLETE, validationTimer_completeHandler);
    }

    private function validationTimer_completeHandler(event:TimerEvent):void
    {
        validateURL();
    }

    private function validateURL():void
    {
        if (!URLUtil.isValidURL(url))
        {
            isURLValidationPending = false;
            displayInvalidURL();
            return;
        }

        isURLValidationPending = true;
        invalidateSkinState();

        prepareURLChecker(buildURL());
        addURLCheckerListeners()

        try
        {
            triggerURLChecker();
        }
        catch (error:Error)
        {
            removeURLCheckerListeners()
            displayInvalidURL();
        }
    }

    protected function displayInvalidURL():void
    {
        isURLValidationPending = false;
        setValidURLInternal(false);
        dispatchEvent(new Event("invalidURL"));
        invalidateSkinState();
    }

    protected function prepareURLChecker(url:String):void
    {
        //subclasses must implement
    }

    private function buildURL():String
    {
        return proxyURL ? proxyURL + "?" + url : url;
    }

    protected function addURLCheckerListeners():void
    {
        //subclasses must implement    
    }

    protected function triggerURLChecker():void
    {
        //subclasses must implement
    }

    protected function removeURLCheckerListeners():void
    {
        //subclasses must implement
    }

    protected function displayValidURL():void
    {
        isURLValidationPending = false;
        setValidURLInternal(true);
        dispatchEvent(new Event("validURL"));
        invalidateSkinState();
    }

    private function setValidURLInternal(value:Boolean):void
    {
        if (_isURLValid != value)
        {
            _isURLValid = value;
            dispatchEvent(new Event("isURLValidChanged"));
        }
    }

    override protected function getCurrentSkinState():String
    {
        if (!enabled)
        {
            return prompt ? "disabledWithPrompt" : "disabled";
        }

        if (text)
        {
            if (isURLValidationPending)
            {
                return "busy";
            }
            else
            {
                return isURLValid ? "valid" : "invalid";
            }
        }
        else
        {
            return prompt ? "normalWithPrompt" : "normal";
        }
    }
}
}
