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
package com.esri.builder.controllers
{

import com.esri.builder.controllers.supportClasses.WellKnownDirectories;
import com.esri.builder.controllers.supportClasses.XMLFileReader;
import com.esri.builder.controllers.supportClasses.processes.BackupDirectoryProcess;
import com.esri.builder.controllers.supportClasses.processes.CleanUpProcess;
import com.esri.builder.controllers.supportClasses.processes.CopyCustomWidgetsProcess;
import com.esri.builder.controllers.supportClasses.processes.CopyRootFilesProcess;
import com.esri.builder.controllers.supportClasses.processes.CopyWidgetsProcess;
import com.esri.builder.controllers.supportClasses.processes.MoveDirectoryProcess;
import com.esri.builder.controllers.supportClasses.processes.ProcessArbiter;
import com.esri.builder.controllers.supportClasses.processes.ProcessArbiterEvent;
import com.esri.builder.controllers.supportClasses.processes.RemoveRootFilesByExtensionProcess;
import com.esri.builder.controllers.supportClasses.processes.TestMoveDirectoryProcess;
import com.esri.builder.controllers.supportClasses.processes.UpdateWebPageFilesProcess;
import com.esri.builder.eventbus.AppEvent;
import com.esri.builder.model.ViewerApp;
import com.esri.builder.views.popups.ApplicationUpgradePopUp;

import flash.display.DisplayObjectContainer;
import flash.filesystem.File;
import flash.filesystem.FileStream;

import mx.core.FlexGlobals;

public class AppUpgradeController
{
    private static const BACKUP_DIRECTORY_NAME:String = "__upgradeViewerBackup__";
    private static const LOCALE_RELATIVE_PATH:String = "assets/locale";

    private var upgradeArbiter:ProcessArbiter;
    private var backupDirectory:File;

    public function AppUpgradeController()
    {
        AppEvent.addListener(AppEvent.UPGRADE_APP_SELECTED, upgradeAppSelectedHandler);
        AppEvent.addListener(AppEvent.UPGRADE_APP, upgradeAppHandler);
    }

    private function upgradeAppSelectedHandler(event:AppEvent):void
    {
        var appUpgradePopUp:ApplicationUpgradePopUp = new ApplicationUpgradePopUp();
        appUpgradePopUp.appToUpgrade = event.data as ViewerApp;
        appUpgradePopUp.open(FlexGlobals.topLevelApplication as DisplayObjectContainer, true);
    }

    private function upgradeAppHandler(event:AppEvent):void
    {
        upgradeApp(event.data as ViewerApp)
    }

    private function upgradeApp(viewerApp:ViewerApp):void
    {
        startUpgradeProcess(viewerApp);
    }

    private function startUpgradeProcess(viewerApp:ViewerApp):void
    {
        var viewerAppDirectory:File = viewerApp.directory;
        backupDirectory = File.applicationStorageDirectory.resolvePath(BACKUP_DIRECTORY_NAME);
        var bundledViewerDirectory:File = WellKnownDirectories.getInstance().bundledFlexViewer;
        var customViewerDirectory:File = WellKnownDirectories.getInstance().customFlexViewer;
        var bundledLocalesDirectory:File = bundledViewerDirectory.resolvePath(LOCALE_RELATIVE_PATH);
        var backupLocalesDirectory:File = backupDirectory.resolvePath(LOCALE_RELATIVE_PATH);

        upgradeArbiter = new ProcessArbiter();
        upgradeArbiter.addEventListener(ProcessArbiterEvent.COMPLETE, upgradeArbiter_completeHandler);
        upgradeArbiter.addEventListener(ProcessArbiterEvent.FAILURE, upgradeArbiter_failureHandler);

        upgradeArbiter.addProcess(new CleanUpProcess(backupDirectory));
        upgradeArbiter.addProcess(new TestMoveDirectoryProcess(viewerAppDirectory));
        upgradeArbiter.addProcess(new BackupDirectoryProcess(viewerAppDirectory, backupDirectory));
        upgradeArbiter.addProcess(new RemoveRootFilesByExtensionProcess(backupDirectory, "swz"));
        upgradeArbiter.addProcess(new CopyRootFilesProcess(bundledViewerDirectory, backupDirectory, rootFileNames));
        upgradeArbiter.addProcess(new CopyRootFilesProcess(bundledLocalesDirectory, backupLocalesDirectory, localeFileNames, false));
        upgradeArbiter.addProcess(new UpdateWebPageFilesProcess(bundledViewerDirectory, backupDirectory, new XMLFileReader(new FileStream())));
        upgradeArbiter.addProcess(new CopyWidgetsProcess(bundledViewerDirectory, backupDirectory));
        upgradeArbiter.addProcess(new CopyCustomWidgetsProcess(customViewerDirectory, backupDirectory));
        upgradeArbiter.addProcess(new MoveDirectoryProcess(backupDirectory, viewerAppDirectory));

        upgradeArbiter.executeProcs();
    }

    protected function upgradeArbiter_completeHandler(event:ProcessArbiterEvent):void
    {
        upgradeArbiter.removeEventListener(ProcessArbiterEvent.COMPLETE, upgradeArbiter_completeHandler);
        upgradeArbiter.removeEventListener(ProcessArbiterEvent.FAILURE, upgradeArbiter_failureHandler);

        AppEvent.dispatch(AppEvent.UPGRADE_APP_COMPLETE);
    }

    protected function upgradeArbiter_failureHandler(event:ProcessArbiterEvent):void
    {
        upgradeArbiter.removeEventListener(ProcessArbiterEvent.COMPLETE, upgradeArbiter_completeHandler);
        upgradeArbiter.removeEventListener(ProcessArbiterEvent.FAILURE, upgradeArbiter_failureHandler);

        var cleanUpProcess:CleanUpProcess = new CleanUpProcess(backupDirectory);
        cleanUpProcess.execute();

        AppEvent.dispatch(AppEvent.UPGRADE_APP_FAILED, event.message);
    }

    public function get rootFileNames():Array
    {
        return [ "index.swf",
                 "playerProductInstall.swf",
                 "version.xml",
                 "charts_4.6.0.23201.swz",
                 "framework_4.6.0.23201.swz",
                 "mx_4.6.0.23201.swz",
                 "osmf_1.0.0.16316.swz",
                 "rpc_4.6.0.23201.swz",
                 "sparkskins_4.6.0.23201.swz",
                 "spark_4.6.0.23201.swz",
                 "textLayout_2.0.0.232.swz",
                 "readme.txt" ];
    }

    public function get localeFileNames():Array
    {
        return [ "ar.swf",
                 "da_DK.swf",
                 "de_DE.swf",
                 "en_US.swf",
                 "es_ES.swf",
                 "et_EE.swf",
                 "fi_FI.swf",
                 "fr_FR.swf",
                 "he_IL.swf",
                 "it_IT.swf",
                 "ja_JP.swf",
                 "ko_KR.swf",
                 "lt_LT.swf",
                 "lv_LV.swf",
                 "nb_NO.swf",
                 "nl_NL.swf",
                 "pl_PL.swf",
                 "pt_BR.swf",
                 "pt_PT.swf",
                 "ro_RO.swf",
                 "ru_RU.swf",
                 "sv_SE.swf",
                 "zh_CN.swf" ];
    }
}
}
