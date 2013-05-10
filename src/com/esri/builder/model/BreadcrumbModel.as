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
package com.esri.builder.model
{

import mx.collections.ArrayList;

public class BreadcrumbModel
{
    public static const instance:BreadcrumbModel = new BreadcrumbModel();

    [Bindable]
    public var trail:ArrayList;

    private var breadcrumbStack:Array;

    public function addBreadcrumb(breadcrumb:Breadcrumb):void
    {
        var breadcrumbLabelIndex:int = findBreadcrumbLabelIndex(breadcrumb.label);

        if (breadcrumbLabelIndex == -1)
        {
            breadcrumbStack.push(breadcrumb);
        }
        else
        {
            breadcrumbStack.splice(breadcrumbLabelIndex + 1);
        }

        trail.source = breadcrumbStack;
    }

    private function findBreadcrumbLabelIndex(label:String):int
    {
        var breadcrumbIndex:int = -1;
        var totalBreadcrumbs:int = breadcrumbStack.length;
        var currentBreadcrumb:Breadcrumb;

        for (var i:int = 0; i < totalBreadcrumbs; i++)
        {
            currentBreadcrumb = breadcrumbStack[i];
            if (currentBreadcrumb.label == label)
            {
                breadcrumbIndex = i;
                break;
            }
        }

        return breadcrumbIndex;
    }

    public function BreadcrumbModel()
    {
        trail = new ArrayList();
        breadcrumbStack = [];
    }

    public function removeLastBreadcrumb():void
    {
        trail.removeItemAt(trail.length - 1);
    }
}
}
