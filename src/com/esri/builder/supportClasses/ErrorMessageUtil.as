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
    public static function getKnownErrorCauseMessage(fault:Fault):String
    {
        var message:String;

        switch (fault.faultCode)
        {
            case "Channel.Security.Error":
            {
                message = ResourceManager.getInstance().getString("BuilderStrings", "serverMissingCrossDomain");
                break;
            }
            case "Server.Error.Request":
            case "400":
            case "404":
            {
                message = ResourceManager.getInstance().getString("BuilderStrings", "serviceIsInaccessible");
                break;
            }
            case "499":
            {
                message = ResourceManager.getInstance().getString("BuilderStrings", "unauthorizedAccess");
                break;
            }
            case "403":
            {
                message = ResourceManager.getInstance().getString("BuilderStrings", "resourceAccessDenied");
                break;
            }
            default:
            {
                if (fault.faultString)
                {
                    message = (fault.faultString == "Sign in aborted") ?
                        ResourceManager.getInstance().getString("BuilderStrings", "signInAborted") :
                        fault.faultString;
                }
                else
                {
                    message = ResourceManager.getInstance().getString("BuilderStrings", "unknownErrorCause");
                }
            }
        }

        return message;
    }
}
}
