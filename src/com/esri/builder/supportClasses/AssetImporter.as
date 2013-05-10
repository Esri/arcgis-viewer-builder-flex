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

import com.esri.builder.model.Model;
import com.esri.builder.supportClasses.LogUtil;

import flash.filesystem.File;

import mx.logging.ILogger;
import mx.logging.Log;

public final class AssetImporter
{
    private static const LOG:ILogger = LogUtil.createLogger(AssetImporter);

    public static function importImage(image:File):File
    {
        if (Log.isInfo())
        {
            LOG.info('Importing {0}', image.nativePath);
        }
        var importedImage:File = Model.instance.appDir.resolvePath('assets' + File.separator + 'images' + File.separator + image.name);
        copyAssetIfDoesNotExist(image, importedImage);

        return importedImage;
    }

    private static function copyAssetIfDoesNotExist(asset:File, importedAsset:File):void
    {
        if (!importedAsset.exists)
        {
            if (Log.isDebug())
            {
                LOG.debug('Does not exist, copying.');
            }
            asset.copyTo(importedAsset, true);
        }
        else
        {
            if (Log.isDebug())
            {
                LOG.debug('Already exists');
            }
        }
    }
}
}
