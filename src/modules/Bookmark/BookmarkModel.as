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
package modules.Bookmark
{

import modules.IWidgetModel;

import mx.collections.ArrayList;

[Bindable]
public final class BookmarkModel implements IWidgetModel
{
    public var bookmarkList:ArrayList = new ArrayList();

    public function BookmarkModel(doc:XML = null)
    {
    }

    public function importXML(doc:XML):void
    {
        var bookmarkXMLList:XMLList = doc..bookmark;
        for (var i:int = 0; i < bookmarkXMLList.length(); i++)
        {
            var name:String = bookmarkXMLList[i].@name;
            var extent:String = bookmarkXMLList[i];
            var extArray:Array = extent.split(" ");

            var bookmark:Bookmark = new Bookmark();
            bookmark.name = name;
            bookmark.xmin = Number(extArray[0]);
            bookmark.ymin = Number(extArray[1]);
            bookmark.xmax = Number(extArray[2]);
            bookmark.ymax = Number(extArray[3]);

            bookmarkList.addItem(bookmark);
        }
    }

    public function exportXML():XML
    {
        const configXML:XML = <configuration/>;
        if (bookmarkList.length)
        {
            const bookmarksXML:XML = <bookmarks/>
            for each (var bookmark:Bookmark in bookmarkList.source)
            {
                bookmarksXML.appendChild(bookmark.encodeXML());
            }
            configXML.appendChild(bookmarksXML);
        }
        return configXML;
    }
}
}
