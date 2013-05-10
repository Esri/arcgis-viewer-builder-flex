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
package modules.DataExtract
{

import com.esri.builder.supportClasses.URLUtil;

import modules.IWidgetModel;

[Bindable]
public final class DataExtractModel implements IWidgetModel
{
    private static const DEF_DATA_EXTRACTION_SERVICE:String = 'http://sampleserver4.arcgisonline.com/ArcGIS/rest/services/HomelandSecurity/Incident_Data_Extraction/GPServer/Extract%20Data%20Task';

    private static const DEF_SELECTION_METHOD:String = 'draw';

    [Domain(values="extent,draw")]
    public var selectionMethod:String = DEF_SELECTION_METHOD;

    private var _dataExtractionService:String = DEF_DATA_EXTRACTION_SERVICE;

    public function get dataExtractionService():String
    {
        return _dataExtractionService;
    }

    public function set dataExtractionService(value:String):void
    {
        _dataExtractionService = URLUtil.encode(value);
    }

    public var useProxy:Boolean;

    public function importXML(doc:XML):void
    {
        dataExtractionService = doc.dataextractionservice || DEF_DATA_EXTRACTION_SERVICE;
        selectionMethod = doc.aioselectionmethod || DEF_SELECTION_METHOD;
        useProxy = doc.useproxy == 'true';
    }

    public function exportXML():XML
    {
        var configXML:XML = <configuration>
                <dataextractionservice>{dataExtractionService}</dataextractionservice>
                <aioselectionmethod>{selectionMethod}</aioselectionmethod>
            </configuration>;

        if (useProxy)
        {
            configXML.appendChild(<useproxy>true</useproxy>);
        }

        return configXML;
    }
}
}
