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

import mx.resources.ResourceManager;
import mx.rpc.Fault;

public class ErrorMessageUtil
{
    public static function getKnownErrorCauseMessage(fault:Fault, fallbackErrorMessage:String = null):String
    {
        return getKnownMessageCodeMessage(fault) || getKnownFaultCodeMessage(fault)
            || getKnownFaultStringMessage(fault) || fallbackErrorMessage
            || getString("unknownErrorCause");
    }

    private static function getKnownMessageCodeMessage(fault:Fault):String
    {
        var message:String;

        var messageCode:String;
        var fallbackMessage:String;

        if (fault.content)
        {
            if (fault.content.hasOwnProperty("messageCode"))
            {
                messageCode = fault.content.messageCode;
            }

            if (fault.content.hasOwnProperty("message"))
            {
                fallbackMessage = fault.content.message;
            }
        }

        if (messageCode == "COM_0057")
        {
            message = getString("unableToSignInPortalUser");
        }
        else if (messageCode == "COM_0056")
        {
            message = getString("unableToSignUpPortalUser");
        }

        return message ? message : fallbackMessage;
    }

    private static function getString(key:String):String
    {
        return ResourceManager.getInstance().getString("BuilderStrings", key);
    }

    private static function getKnownFaultCodeMessage(fault:Fault):String
    {
        var message:String;

        var faultCode:String = fault.faultCode;

        if (faultCode == "Channel.Security.Error")
        {
            message = getString("serverMissingCrossDomain");
        }
        else if (faultCode == "400" || faultCode == "404"
            || faultCode == "Server.Error.Request")
        {
            message = getString("serviceIsInaccessible");
        }
        else if (faultCode == "499")
        {
            message = getString("unauthorizedAccess");
        }
        else if (faultCode == "403")
        {
            message = getString("resourceAccessDenied");
        }

        return message;
    }

    private static function getKnownFaultStringMessage(fault:Fault):String
    {
        var message:String;

        var faultString:String = fault.faultString;
        if (faultString)
        {
            message = (faultString == "Sign in aborted") ?
                getString("signInAborted") : faultString;
        }

        return message;
    }
}
}
