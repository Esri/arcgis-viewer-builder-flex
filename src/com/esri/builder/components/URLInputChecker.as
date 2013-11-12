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

import flash.net.URLRequestMethod;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;
import mx.rpc.mxml.Concurrency;

[Exclude(kind="property", name="text")]

[SkinState("busy")]
[SkinState("valid")]
[SkinState("invalid")]

public class URLInputChecker extends URLInputCheckerBase
{
    private var urlRequest:HTTPService;
    private var requestMethodChanged:Boolean;
    private var resultFormatChanged:Boolean;

    private var _resultFormat:String = HTTPService.RESULT_FORMAT_TEXT;

    [Bindable]
    public function get resultFormat():String
    {
        return _resultFormat;
    }

    [Inspectable(
        enumeration="object,array,xml,flashvars,text,e4x",
        defaultValue="object",
        category="General")]
    public function set resultFormat(value:String):void
    {
        if (_resultFormat != value)
        {
            _resultFormat = value;
            resultFormatChanged = true;
            invalidateProperties();
        }
    }

    private var _requestMethod:String = URLRequestMethod.HEAD;

    [Bindable]
    public function get requestMethod():String
    {
        return _requestMethod;
    }

    [Inspectable(
        enumeration="GET,get,POST,post,HEAD,head,OPTIONS,options,PUT,put,TRACE,trace,DELETE,delete",
        defaultValue="GET",
        category="General")]
    public function set requestMethod(value:String):void
    {
        if (_requestMethod != value)
        {
            _requestMethod = value;
            requestMethodChanged = true;
            invalidateProperties();
        }
    }

    override protected function commitProperties():void
    {
        if (requestTimeoutChanged)
        {
            urlRequest.requestTimeout = requestTimeout;
            requestTimeoutChanged = false;
        }

        if (resultFormatChanged)
        {
            urlRequest.resultFormat = resultFormat;
            resultFormatChanged = false;
        }

        if (requestMethodChanged)
        {
            urlRequest.method = requestMethod;
            requestMethodChanged = false;
        }

        super.commitProperties();
    }

    override protected function initURLChecker():void
    {
        urlRequest = new HTTPService();
        urlRequest.method = requestMethod;
        urlRequest.resultFormat = resultFormat;
        urlRequest.requestTimeout = requestTimeout;
        urlRequest.concurrency = Concurrency.LAST;
    }

    override protected function triggerURLChecker():void
    {
        super.triggerURLChecker();
        urlRequest.send();
    }

    override protected function cancelURLValidationInProgress():void
    {
        urlRequest.cancel();
        super.cancelURLValidationInProgress();
    }

    override protected function prepareURLChecker(url:String):void
    {
        urlRequest.url = URLUtil.ensureValidKeyValuePairs(URLUtil.removeToken(url));
    }

    override protected function addURLCheckerListeners():void
    {
        urlRequest.addEventListener(ResultEvent.RESULT, urlRequest_resultHandler);
        urlRequest.addEventListener(FaultEvent.FAULT, urlRequest_faultHandler);
    }

    protected function urlRequest_resultHandler(event:ResultEvent):void
    {
        removeURLCheckerListeners();

        if (responseValidationFunction == null
            || responseValidationFunction(event.result))
        {
            displayValidURL();
        }
        else
        {
            displayInvalidURL(fallbackErrorMessage);
        }
    }

    override protected function removeURLCheckerListeners():void
    {
        urlRequest.removeEventListener(ResultEvent.RESULT, urlRequest_resultHandler);
        urlRequest.removeEventListener(FaultEvent.FAULT, urlRequest_faultHandler);
    }

    protected function urlRequest_faultHandler(event:FaultEvent):void
    {
        removeURLCheckerListeners();
        displayInvalidURL(getInvalidMessage(event.fault));
    }

    override protected function requestURLValidation():void
    {
        if (enabled)
        {
            urlRequest.cancel();
        }
        super.requestURLValidation();
    }
}
}
