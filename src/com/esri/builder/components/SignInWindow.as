////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2008-2016 Esri. All Rights Reserved.
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

import com.esri.ags.components.supportClasses.Credential;
import com.esri.ags.skins.supportClasses.SignInWindow;
import com.esri.builder.eventbus.AppEvent;

public class SignInWindow extends com.esri.ags.skins.supportClasses.SignInWindow
{
    override protected function generateCredentialResult(credential:Credential):void
    {
        super.generateCredentialResult(credential);
        AppEvent.dispatch(AppEvent.IDENTITY_MANAGER_SIGN_IN_SUCCESS, credential);
    }
}
}
