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

import flash.desktop.ClipboardFormats;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeDragEvent;
import flash.filesystem.File;
import flash.net.FileFilter;

import mx.core.IUIComponent;
import mx.managers.DragManager;

import spark.components.Button;
import spark.components.Image;
import spark.components.supportClasses.SkinnableComponent;

[Event(name="change", type="flash.events.Event")]
[SkinState("normal")]
[SkinState("dropTargetAcceptable")]
public class ImageBrowser extends SkinnableComponent
{
    [SkinPart(required="false", type="spark.components.Image")]
    public var previewImage:Image;
    [SkinPart(required="true", type="spark.components.Button")]
    public var browseButton:Button;
    [SkinPart(required="true", type="flash.display.InteractiveObject")]
    public var dropArea:InteractiveObject;

    [Bindable]
    private var selectedImageURL:String;

    private var isDropTargetAcceptable:Boolean = false;

    private var _selectedImage:File;

    [Bindable]
    public function get selectedImage():File
    {
        return _selectedImage;
    }

    public function set selectedImage(value:File):void
    {
        _selectedImage = value;
        if (_selectedImage)
        {
            selectedImageURL = _selectedImage.url;
            dispatchEvent(new Event(Event.CHANGE));
        }
    }

    [Bindable(event="change")]
    public function get selectedImagePath():String
    {
        return selectedImageURL;
    }

    public function loadImageFromDirectory(directory:File, relativeImagePath:String):void
    {
        if (!directory || !directory.exists || !directory.isDirectory
            || !relativeImagePath)
        {
            return;
        }

        var imageFile:File = directory.resolvePath(relativeImagePath);
        if (imageFile.exists)
        {
            selectedImage = imageFile;
        }
    }

    public function loadImageFromURL(url:String):void
    {
        selectedImageURL = url;
        dispatchEvent(new Event(Event.CHANGE));
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);

        if (instance == dropArea)
        {
            dropArea.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler, false, 0, true);
            dropArea.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler, false, 0, true);
            dropArea.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, nativeDragExitHandler, false, 0, true);
        }
        else if (instance == browseButton)
        {
            browseButton.addEventListener(MouseEvent.CLICK, browseButton_clickHandler, false, 0, true);
        }
    }

    private function nativeDragEnterHandler(event:NativeDragEvent):void
    {
        if (event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
        {
            const files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
            if (files && files.length == 1)
            {
                const name:String = files[0].name;
                const pattern:RegExp = /.+\.(jpeg|jpg|png|gif)$/i;
                if (name.toLowerCase().match(pattern))
                {
                    DragManager.acceptDragDrop(event.currentTarget as IUIComponent);
                    isDropTargetAcceptable = true;
                    invalidateSkinState();
                }
            }
        }
    }

    private function nativeDragDropHandler(event:NativeDragEvent):void
    {
        var clipboardData:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
        if (clipboardData && clipboardData.length)
        {
            selectedImage = clipboardData[0] as File;
            isDropTargetAcceptable = false;
            invalidateSkinState();
        }
    }

    private function nativeDragExitHandler(event:NativeDragEvent):void
    {
        isDropTargetAcceptable = false;
        invalidateSkinState();
    }

    override protected function getCurrentSkinState():String
    {
        return isDropTargetAcceptable ? "dropTargetAcceptable" : "normal";
    }

    protected function browseButton_clickHandler(event:MouseEvent):void
    {
        startImageFileBrowse();
    }

    private function startImageFileBrowse():void
    {
        var fileFilter:FileFilter = new FileFilter(resourceManager.getString('BuilderStrings', 'widgetsView.filter'), "*.jpeg;*.jpg;*.png;*.gif");
        var imageBrowseFile:File = new File();
        imageBrowseFile.addEventListener(Event.SELECT, imageBrowseFile_selectHandler);
        imageBrowseFile.browseForOpen(resourceManager.getString('BuilderStrings', 'widgetsView.select'), [ fileFilter ]);
    }

    private function imageBrowseFile_selectHandler(event:Event):void
    {
        selectedImage = event.target as File;
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == dropArea)
        {
            dropArea.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, nativeDragEnterHandler);
            dropArea.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, nativeDragDropHandler);
            dropArea.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, nativeDragExitHandler);
        }
        else if (instance == browseButton)
        {
            browseButton.removeEventListener(MouseEvent.CLICK, browseButton_clickHandler);
        }
    }
}
}
