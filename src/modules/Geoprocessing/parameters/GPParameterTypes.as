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
package modules.Geoprocessing.parameters
{

public class GPParameterTypes
{
    public static const BOOLEAN:String = "boolean";
    public static const STRING:String = "string";
    public static const LONG:String = "long";
    public static const DOUBLE:String = "double";
    public static const DATE:String = "date";
    public static const DATA_FILE:String = "datafile";
    public static const LINEAR_UNIT:String = "linearunit";
    public static const RECORD_SET:String = "recordset";
    public static const FEATURE_RECORD_SET_LAYER:String = "featurerecordset";
    public static const RASTER_DATA_LAYER:String = "rasterdatalayer";
    public static const MULTI_VALUE_BOOLEAN:String = "multivalue:boolean";
    public static const MULTI_VALUE_DATAFILE:String = "multivalue:datafile";
    public static const MULTI_VALUE_DATE:String = "multivalue:date";
    public static const MULTI_VALUE_DOUBLE:String = "multivalue:double";
    public static const MULTI_VALUE_FEATURE_RECORD_SET:String = "multivalue:featurerecordset";
    public static const MULTI_VALUE_LINEAR_UNIT:String = "multivalue:linearunit";
    public static const MULTI_VALUE_LONG:String = "multivalue:long";
    public static const MULTI_VALUE_RASTER_DATA_LAYER:String = "multivalue:rasterdatalayer";
    public static const MULTI_VALUE_RECORD_SET:String = "multivalue:recordset";
    public static const MULTI_VALUE_STRING:String = "multivalue:string";

    public static const GP_BOOLEAN:String = "GPBoolean";
    public static const GP_STRING:String = "GPString";
    public static const GP_LONG:String = "GPLong";
    public static const GP_DOUBLE:String = "GPDouble";
    public static const GP_DATE:String = "GPDate";
    public static const GP_DATA_FILE:String = "GPDataFile";
    public static const GP_LINEAR_UNIT:String = "GPLinearUnit";
    public static const GP_RECORD_SET:String = "GPRecordSet";
    public static const GP_FEATURE_RECORD_SET_LAYER:String = "GPFeatureRecordSetLayer";
    public static const GP_RASTER_DATA_LAYER:String = "GPRasterDataLayer";
    public static const GP_MULTI_VALUE_BOOLEAN:String = "GPMultiValue:GPBoolean";
    public static const GP_MULTI_VALUE_DATA_FILE:String = "GPMultiValue:GPDataFile";
    public static const GP_MULTI_VALUE_DATE:String = "GPMultiValue:GPDate";
    public static const GP_MULTI_VALUE_DOUBLE:String = "GPMultiValue:GPDouble";
    public static const GP_MULTI_VALUE_FEATURE_RECORD_SET_LAYER:String = "GPMultiValue:GPFeatureRecordSetLayer";
    public static const GP_MULTI_VALUE_LINEAR_UNIT:String = "GPMultiValue:GPLinearUnit";
    public static const GP_MULTI_VALUE_LONG:String = "GPMultiValue:GPLong";
    public static const GP_MULTI_VALUE_RASTER_DATA_LAYER:String = "GPMultiValue:GPRasterDataLayer";
    public static const GP_MULTI_VALUE_RECORD_SET:String = "GPMultiValue:GPRecordSet";
    public static const GP_MULTI_VALUE_STRING:String = "GPMultiValue:GPString";

    public static function toPrettyDataType(gpDataType:String):String
    {
        var prettyDataType:String;

        switch (gpDataType)
        {
            case GPParameterTypes.GP_BOOLEAN:
            {
                prettyDataType = GPParameterTypes.BOOLEAN;
                break;
            }
            case GPParameterTypes.GP_DATA_FILE:
            {
                prettyDataType = GPParameterTypes.DATA_FILE;
                break;
            }
            case GPParameterTypes.GP_DATE:
            {
                prettyDataType = GPParameterTypes.DATE;
                break;
            }
            case GPParameterTypes.GP_DOUBLE:
            {
                prettyDataType = GPParameterTypes.DOUBLE;
                break;
            }
            case GPParameterTypes.GP_FEATURE_RECORD_SET_LAYER:
            {
                prettyDataType = GPParameterTypes.FEATURE_RECORD_SET_LAYER;
                break;
            }
            case GPParameterTypes.GP_LINEAR_UNIT:
            {
                prettyDataType = GPParameterTypes.LINEAR_UNIT;
                break;
            }
            case GPParameterTypes.GP_LONG:
            {
                prettyDataType = GPParameterTypes.LONG;
                break;
            }
            case GPParameterTypes.GP_RASTER_DATA_LAYER:
            {
                prettyDataType = GPParameterTypes.RASTER_DATA_LAYER;
                break;
            }
            case GPParameterTypes.GP_RECORD_SET:
            {
                prettyDataType = GPParameterTypes.RECORD_SET;
                break;
            }
            case GPParameterTypes.GP_STRING:
            {
                prettyDataType = GPParameterTypes.STRING;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_BOOLEAN:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_BOOLEAN;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_DATE:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_DATE;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_DATA_FILE:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_DATAFILE;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_DOUBLE:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_DOUBLE;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_FEATURE_RECORD_SET_LAYER:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_FEATURE_RECORD_SET;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_LINEAR_UNIT:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_LINEAR_UNIT;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_LONG:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_LONG;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_RASTER_DATA_LAYER:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_RASTER_DATA_LAYER;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_RECORD_SET:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_RECORD_SET;
                break;
            }
            case GPParameterTypes.GP_MULTI_VALUE_STRING:
            {
                prettyDataType = GPParameterTypes.MULTI_VALUE_STRING;
                break;
            }
        }

        return prettyDataType;
    }
}

}
