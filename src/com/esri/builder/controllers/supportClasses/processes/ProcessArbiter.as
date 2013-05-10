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
package com.esri.builder.controllers.supportClasses.processes
{

import com.esri.builder.controllers.supportClasses.*;

import flash.events.EventDispatcher;

public class ProcessArbiter extends EventDispatcher
{
    private var processes:Array = [];

    public function get hasProcs():Object
    {
        return processes.length > 0;
    }

    public function addProcess(process:Process):void
    {
        processes.push(process);
    }

    public function executeProcs():void
    {
        executeProcess();
    }

    private function executeProcess():void
    {
        var currentProcess:Process = processes.shift();
        if (currentProcess)
        {
            currentProcess.addEventListener(ProcessEvent.SUCCESS, currentProgress_successHandler);
            currentProcess.addEventListener(ProcessEvent.PROGRESS, currentProgress_progressHandler);
            currentProcess.addEventListener(ProcessEvent.FAILURE, currentProgress_failureHandler);
            currentProcess.execute();
        }
        else
        {
            dispatchEvent(new ProcessArbiterEvent(ProcessArbiterEvent.COMPLETE, "Upgrade complete!"));
        }
    }

    private function currentProgress_successHandler(event:ProcessEvent):void
    {
        (event.currentTarget as EventDispatcher).removeEventListener(ProcessEvent.SUCCESS, currentProgress_successHandler);
        (event.currentTarget as EventDispatcher).removeEventListener(ProcessEvent.FAILURE, currentProgress_failureHandler);
        dispatchEvent(new ProcessArbiterEvent(ProcessArbiterEvent.PROGRESS, event.message));
        executeProcess();
    }

    private function currentProgress_progressHandler(event:ProcessEvent):void
    {
        (event.currentTarget as EventDispatcher).removeEventListener(ProcessEvent.SUCCESS, currentProgress_successHandler);
        (event.currentTarget as EventDispatcher).removeEventListener(ProcessEvent.FAILURE, currentProgress_failureHandler);
        dispatchEvent(new ProcessArbiterEvent(ProcessArbiterEvent.PROGRESS, event.message));
        executeProcess();
    }

    private function currentProgress_failureHandler(event:ProcessEvent):void
    {
        (event.currentTarget as EventDispatcher).removeEventListener(ProcessEvent.SUCCESS, currentProgress_successHandler);
        (event.currentTarget as EventDispatcher).removeEventListener(ProcessEvent.FAILURE, currentProgress_failureHandler);
        dropProcs();
        dispatchEvent(new ProcessArbiterEvent(ProcessArbiterEvent.FAILURE, event.message));
    }

    private function dropProcs():void
    {
        var totalProcs:int = processes.length;
        for (var i:int = 0; i < totalProcs; i++)
        {
            processes.pop();
        }
    }
}
}
