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

import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.operations.FlowOperation;
import flashx.textLayout.operations.UndoOperation;

import mx.collections.ArrayList;
import mx.events.FlexEvent;
import mx.utils.StringUtil;

import spark.components.Button;
import spark.components.List;
import spark.components.TextInput;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.TextOperationEvent;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The directionality of the text displayed by the component.
 */
[Style(name="direction", type="String", enumeration="ltr,rtl", inherit="yes")]

//--------------------------------------
//  SkinStates
//--------------------------------------

/**
 *
 */
[SkinState("normal")]

/**
 *
 */
[SkinState("suggesting")]

//--------------------------------------
//  Events
//--------------------------------------

[Event(name="search", type="com.esri.builder.components.SearchInputEvent")]

/**
 *
 */
public class SearchInput extends SkinnableComponent
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     * Constructor
     */
    public function SearchInput()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var originalSearchTextInputValue:String;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  suggestedFocusSkinExclusions
    //----------------------------------
    /**
     * @private
     */
    private static const focusExclusions:Array = [ "suggestionList" ];

    /**
     *  @private
     */
    override public function get suggestedFocusSkinExclusions():Array
    {
        return focusExclusions;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  hasText
    //----------------------------------

    [Bindable(event="textChanged")]
    public function get hasText():Boolean
    {
        return searchTextInputValue && searchTextInputValue.length > 0;
    }

    //----------------------------------
    //  searchTextInputToolTip
    //----------------------------------

    [Bindable]
    public var searchTextInputToolTip:String;

    //----------------------------------
    //  searchButtonLabel
    //----------------------------------

    [Bindable]
    public var searchButtonLabel:String;

    //----------------------------------
    //  searchButtonToolTip
    //----------------------------------

    [Bindable]
    public var searchButtonToolTip:String;

    //----------------------------------
    //  searchHistory
    //----------------------------------

    private var m_searchHistory:Array;

    /**
     *
     */
    public function get searchHistory():Array
    {
        return m_searchHistory;
    }

    public function set searchHistory(value:Array):void
    {
        m_searchHistory = value;
        if (searchTextInputValue && searchTextInputValue != "")
        {
            // Don't show the popup
            if (suggestionList && currentState == "normal")
            {
                suggestionList.dataProvider = null;
            }
        }
    }

    //--------------------------------------------------------------------------
    //  searchTextInputValue
    //--------------------------------------------------------------------------

    private var _searchTextInputValue:String;

    [Bindable(event="textChanged")]
    public function get searchTextInputValue():String
    {
        return _searchTextInputValue;
    }

    public function set searchTextInputValue(value:String):void
    {
        _searchTextInputValue = value;
        dispatchEvent(new Event("textChanged"));
    }

    //----------------------------------
    //  text
    //---------------------------------- 

    [Bindable(event="textChanged")]
    public function get text():String
    {
        return searchTextInputValue;
    }

    public function set text(value:String):void
    {
        if (searchTextInputValue != value)
        {
            searchTextInputValue = value;
            searchTextInput.text = searchTextInputValue;
            suggestionList.dataProvider = null;
            invalidateSkinState();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  searchTextInput
    //---------------------------------- 

    [SkinPart(required="true")]

    /**
     *
     */
    public var searchTextInput:TextInput;

    //----------------------------------
    //  suggestionList
    //---------------------------------- 

    [SkinPart(required="true")]

    /**
     *
     */
    public var suggestionList:List;

    //----------------------------------
    //  searchButton
    //---------------------------------- 

    [SkinPart(required="false")]

    /**
     *
     */
    public var searchButton:Button;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods : Invalidation
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Overridden methods : Skin management
    //
    //--------------------------------------------------------------------------

    override protected function getCurrentSkinState():String
    {
        var state:String = "normal";
        if (suggestionList && suggestionList.dataProvider && suggestionList.dataProvider.length > 0)
        {
            state = "suggesting";
        }
        return state;
    }

    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        if (instance === searchTextInput)
        {
            searchTextInput.addEventListener(FocusEvent.FOCUS_IN, searchTextInput_focusInHandler);
            searchTextInput.addEventListener(TextOperationEvent.CHANGE, searchTextInput_changeHandler);
            searchTextInput.addEventListener(FlexEvent.ENTER, searchTextInput_enterHandler);
            searchTextInput.addEventListener(FocusEvent.FOCUS_OUT, searchTextInput_focusOutHandler);
            searchTextInput.addEventListener(KeyboardEvent.KEY_DOWN, searchTextInput_keyDownHandler);
            searchTextInput.text = searchTextInputValue;
            searchTextInput.selectAll();
        }
        else if (instance === suggestionList)
        {
            suggestionList.addEventListener(MouseEvent.CLICK, suggestionList_clickHandler);
        }
        else if (instance === searchButton)
        {
            searchButton.addEventListener(MouseEvent.CLICK, searchButton_clickHandler);
        }
    }

    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        if (instance === searchTextInput)
        {
            searchTextInput.removeEventListener(FocusEvent.FOCUS_IN, searchTextInput_focusInHandler);
            searchTextInput.removeEventListener(TextOperationEvent.CHANGE, searchTextInput_changeHandler);
            searchTextInput.removeEventListener(FlexEvent.ENTER, searchTextInput_enterHandler);
            searchTextInput.removeEventListener(FocusEvent.FOCUS_OUT, searchTextInput_focusOutHandler);
            searchTextInput.removeEventListener(KeyboardEvent.KEY_DOWN, searchTextInput_keyDownHandler);
        }
        else if (instance === suggestionList)
        {
            suggestionList.removeEventListener(MouseEvent.CLICK, suggestionList_clickHandler);
        }
        else if (instance === searchButton)
        {
            searchButton.removeEventListener(MouseEvent.CLICK, searchButton_clickHandler);
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods : Focus Management
    //
    //--------------------------------------------------------------------------

    override public function setFocus():void
    {
        if (searchTextInput)
        {
            searchTextInput.setFocus();
            searchTextInput.selectAll();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private function searchInHistory(input:String):void
    {
        const searchResults:Array = [];

        if (input)
        {
            for (var i:int = m_searchHistory.length - 1; i >= 0; i--)
            {
                if (m_searchHistory[i].indexOf(input) != -1)
                {
                    searchResults.unshift(m_searchHistory[i]);
                    if (searchResults.length >= 10)
                    {
                        break;
                    }
                }
            }
        }

        suggestionList.dataProvider = new ArrayList(searchResults);
        suggestionList.selectedIndex = -1;

        invalidateSkinState();
    }

    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------

    protected function searchButton_clickHandler(event:MouseEvent):void
    {
        dispatchSearchEvent();
    }

    protected function searchTextInput_enterHandler(event:FlexEvent):void
    {
        dispatchSearchEvent();
    }

    protected function searchTextInput_changeHandler(event:TextOperationEvent):void
    {
        searchTextInputValue = getOperationText(event.operation);

        if (m_searchHistory
            && m_searchHistory.length > 0)
        {
            searchInHistory(searchTextInputValue);
        }
    }

    private function getOperationText(operation:FlowOperation):String
    {
        const undo:UndoOperation = operation as UndoOperation;
        const operationTextFlow:TextFlow = undo ? undo.operation.textFlow : operation.textFlow;
        return operationTextFlow ? StringUtil.trim(operationTextFlow.getText()) : "";
    }

    private function searchTextInput_keyDownHandler(event:KeyboardEvent):void
    {
        if (event.keyCode == Keyboard.DOWN)
        {
            processDownKey();
        }
        else if (event.keyCode == Keyboard.UP)
        {
            processUpKey();
        }
        else if (event.keyCode == Keyboard.ESCAPE)
        {
            processEscapeKey();
        }
    }

    private function processDownKey():void
    {
        if (!suggestionList.dataProvider)
        {
            searchInHistory(StringUtil.trim(searchTextInput.text));
            return;
        }

        if (suggestionList.selectedIndex == -1)
        {
            originalSearchTextInputValue = StringUtil.trim(searchTextInput.text);
        }

        if (suggestionList.selectedIndex != suggestionList.dataProvider.length - 1)
        {
            suggestionList.selectedIndex++;
            searchTextInput.text = suggestionList.selectedItem;
        }
        else
        {
            suggestionList.selectedIndex = -1;
            searchTextInput.text = originalSearchTextInputValue;
        }

        searchTextInputValue = StringUtil.trim(searchTextInput.text)
        searchTextInput.selectRange(searchTextInput.text.length, searchTextInput.text.length);
    }

    private function processUpKey():void
    {
        if (!suggestionList.dataProvider)
        {
            searchInHistory(StringUtil.trim(searchTextInput.text));
            return;
        }

        if (suggestionList.selectedIndex == -1)
        {
            originalSearchTextInputValue = StringUtil.trim(searchTextInput.text);
            suggestionList.selectedIndex = suggestionList.dataProvider.length - 1;
            searchTextInput.text = suggestionList.selectedItem;
        }
        else if (suggestionList.selectedIndex >= 0 && suggestionList.selectedIndex <= suggestionList.dataProvider.length - 1)
        {
            suggestionList.selectedIndex--;
            if (suggestionList.selectedIndex > -1)
            {
                searchTextInput.text = suggestionList.selectedItem;
            }
            else
            {
                searchTextInput.text = originalSearchTextInputValue;
            }
        }

        searchTextInputValue = StringUtil.trim(searchTextInput.text);
        searchTextInput.selectRange(searchTextInput.text.length, searchTextInput.text.length);
    }

    private function processEscapeKey():void
    {
        suggestionList.dataProvider = null;
        invalidateSkinState();
        searchTextInput.selectRange(0, searchTextInput.text.length);
    }

    protected function searchTextInput_focusInHandler(event:FocusEvent):void
    {
        searchTextInput.selectAll();
    }

    protected function searchTextInput_focusOutHandler(event:FocusEvent):void
    {
        const focusedObject:InteractiveObject = event.relatedObject;
        if (focusedObject == null)
        {
            suggestionList.dataProvider = null;
            invalidateSkinState();
            return;
        }

        var focusOnList:Boolean = focusedObject == suggestionList;
        if (!focusOnList)
        {
            var tempDisplayObjectContainer:DisplayObjectContainer = focusedObject.parent;
        }

        while (!focusOnList && tempDisplayObjectContainer != null)
        {
            focusOnList = tempDisplayObjectContainer == suggestionList;
            tempDisplayObjectContainer = tempDisplayObjectContainer.parent;
        }

        if (!focusOnList)
        {
            suggestionList.dataProvider = null;
            invalidateSkinState();
        }
    }

    protected function suggestionList_clickHandler(event:MouseEvent):void
    {
        searchTextInput.setFocus();

        if (suggestionList.selectedIndex != -1)
        {
            text = suggestionList.selectedItem;
            dispatchSearchEvent();
        }
        searchTextInput.selectRange(searchTextInput.text.length, searchTextInput.text.length);
    }

    private function dispatchSearchEvent():void
    {
        suggestionList.dataProvider = null;
        invalidateSkinState();

        if (searchTextInputValue)
        {
            searchTextInput.selectRange(searchTextInputValue.length, searchTextInputValue.length);
            dispatchEvent(new SearchInputEvent(searchTextInputValue));
        }
    }
}
}
