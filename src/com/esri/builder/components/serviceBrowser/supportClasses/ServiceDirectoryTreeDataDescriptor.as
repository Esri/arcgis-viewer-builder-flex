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
package com.esri.builder.components.serviceBrowser.supportClasses
{

import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryNode;

import mx.collections.ICollectionView;
import mx.controls.treeClasses.DefaultDataDescriptor;

public class ServiceDirectoryTreeDataDescriptor extends DefaultDataDescriptor
{
    override public function getChildren(node:Object, model:Object = null):ICollectionView
    {
        const sdNode:ServiceDirectoryNode = node as ServiceDirectoryNode;

        if (sdNode)
        {
            sdNode.loadChildren();
            return sdNode.children;
        }
        else
        {
            return super.getChildren(node, model);
        }
    }

    override public function hasChildren(node:Object, model:Object = null):Boolean
    {
        const sdNode:ServiceDirectoryNode = node as ServiceDirectoryNode;

        if (sdNode)
        {
            return sdNode.hasChildren;
        }
        else
        {
            return super.hasChildren(node, model);
        }
    }

    override public function isBranch(node:Object, model:Object = null):Boolean
    {
        const sdNode:ServiceDirectoryNode = node as ServiceDirectoryNode;

        if (sdNode)
        {
            return sdNode.isBranch;
        }
        else
        {
            return super.isBranch(node, model);
        }
    }
}
}
