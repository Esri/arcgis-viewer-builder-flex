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

import com.esri.ags.portal.supportClasses.PopUpFieldInfo;

import mx.utils.StringUtil;

public class PopUpFieldPicker extends FieldPickerBase
{
    override protected function selectedFieldNameAt(index:int):String
    {
        var selectedField:PopUpFieldInfo = fieldList.dataProvider.getItemAt(index) as PopUpFieldInfo;
        return selectedField.fieldName;
    }

    override public function defaultFieldLabelFunction(field:Object):String
    {
        return StringUtil.substitute("{0} {{1}}", field.label, field.fieldName);
    }
}
}
