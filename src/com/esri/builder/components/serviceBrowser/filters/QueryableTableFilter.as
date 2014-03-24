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
package com.esri.builder.components.serviceBrowser.filters
{

import com.esri.builder.components.serviceBrowser.nodes.FeatureServerNode;
import com.esri.builder.components.serviceBrowser.nodes.FolderNode;
import com.esri.builder.components.serviceBrowser.nodes.LayerNode;
import com.esri.builder.components.serviceBrowser.nodes.MapServerNode;
import com.esri.builder.components.serviceBrowser.nodes.ServiceDirectoryNode;
import com.esri.builder.components.serviceBrowser.nodes.TableNode;

public class QueryableTableFilter implements INodeFilter
{
    public function isApplicable(node:ServiceDirectoryNode):Boolean
    {
        return node is FolderNode
            || node is FeatureServerNode
            || node is MapServerNode
            || isNodeQueryable(node);
    }

    private function isNodeQueryable(node:ServiceDirectoryNode):Boolean
    {
		const tableNode:TableNode = node as TableNode;
		return tableNode && tableNode.isQueryable;
    }

    public function isSelectable(node:ServiceDirectoryNode):Boolean
    {
        return isNodeQueryable(node);
    }

    public function get serverChildrenAllowed():Boolean
    {
        return true;
    }
}
}
