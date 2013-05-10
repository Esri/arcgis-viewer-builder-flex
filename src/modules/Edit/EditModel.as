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
package modules.Edit
{

import modules.IWidgetModel;
import modules.supportClasses.LayerSettings;

import mx.collections.ArrayList;

public final class EditModel implements IWidgetModel
{
    [Bindable]
    public var excludedLayers:ArrayList;

    [Bindable]
    public var addFeatures:Boolean = true;
    [Bindable]
    public var deleteFeatures:Boolean = true;
    [Bindable]
    public var updateGeometry:Boolean = true;
    [Bindable]
    public var updateAttributes:Boolean = true;
    [Bindable]
    public var toolbarVisible:Boolean = false;
    [Bindable]
    public var toolbarCut:Boolean = true;
    [Bindable]
    public var toolbarMerge:Boolean = true;
    [Bindable]
    public var toolbarReshape:Boolean = true;
    [Bindable]
    public var formFieldsOrder:String;

    public var layerSettings:Array = [];

    private var attributesLabel:String;
    private var attachmentsLabel:String;
    private var relatedRecordsLabel:String;
    private var featureLayerNotVisibleLabel:String;
    private var saveLabel:String;
    private var deleteLabel:String;
    private var showAttachmentsLabel:String;
    private var showRelatedRecordsLabel:String;
    private var noAttachmentsLabel:String;
    private var chooseFileLabel:String;
    private var attachmentSubmitLabel:String;
    private var attachmentCancelLabel:String;
    private var showAttributesLabel:String;
    private var noEditableLayersLabel:String;

    public function EditModel()
    {
        excludedLayers = new ArrayList();
    }

    public function importXML(doc:XML):void
    {
        addFeatures = (doc.addfeatures[0] == "true");
        deleteFeatures = (doc.deletefeatures[0] == "true");
        updateGeometry = (doc.updategeometry[0] == "true");
        updateAttributes = (doc.updateattributes[0] == "true");
        toolbarVisible = (doc.toolbarvisible[0] == "true");
        toolbarCut = (doc.toolbarcutvisible[0] == "true");
        toolbarMerge = (doc.toolbarmergevisible[0] == "true");
        toolbarReshape = (doc.toolbarreshapevisible[0] == "true");
        formFieldsOrder = doc.formfieldsorder[0];

        var excludedLayersXML:XMLList = doc.excludelayer;
        for each (var excludedLayerNameXML:XML in excludedLayersXML)
        {
            excludedLayers.addItem(excludedLayerNameXML.toString());
        }

        var parsedLayerSettings:LayerSettings;
        for each (var settings:XML in doc.layersettings.layer)
        {
            parsedLayerSettings = new LayerSettings();
            parsedLayerSettings.fromXML(settings);
            if (parsedLayerSettings.name)
            {
                layerSettings.push(parsedLayerSettings);
            }
        }

        parseLabels(doc);
    }

    private function parseLabels(doc:XML):void
    {
        var parsedAttributesLabel:String = (doc.labels.attributeslabel[0] || doc.attributeslabel[0]);
        if (parsedAttributesLabel)
        {
            attributesLabel = parsedAttributesLabel;
        }

        var parsedAttachmentsLabel:String = (doc.labels.attachmentslabel[0] || doc.attachmentslabel[0]);
        if (parsedAttachmentsLabel)
        {
            attachmentsLabel = parsedAttachmentsLabel;
        }

        var parsedRelatedRecordsLabel:String = (doc.labels.relatedrecordslabel[0] || doc.relatedrecordslabel[0]);
        if (parsedRelatedRecordsLabel)
        {
            relatedRecordsLabel = parsedRelatedRecordsLabel;
        }

        var parsedFeatureLayerNotVisibleLabel:String = (doc.labels.featurelayernotvisibletext[0] || doc.featurelayernotvisibletext[0]);
        if (parsedFeatureLayerNotVisibleLabel)
        {
            featureLayerNotVisibleLabel = parsedFeatureLayerNotVisibleLabel;
        }

        //new label structure tags
        if (doc.labels.savelabel[0])
        {
            saveLabel = doc.labels.savelabel[0];
        }

        if (doc.labels.deletelabel[0])
        {
            deleteLabel = doc.labels.deletelabel[0];
        }

        if (doc.labels.showattachmentstext[0])
        {
            showAttachmentsLabel = doc.labels.showattachmentstext[0];
        }

        if (doc.labels.showrelatedrecordstext[0])
        {
            showRelatedRecordsLabel = doc.labels.showrelatedrecordstext[0];
        }

        if (doc.labels.noattachmentstext[0])
        {
            noAttachmentsLabel = doc.labels.noattachmentstext[0];
        }

        if (doc.labels.choosefiletext[0])
        {
            chooseFileLabel = doc.labels.choosefiletext[0];
        }

        if (doc.labels.attachmentsubmitlabel[0])
        {
            attachmentSubmitLabel = doc.labels.attachmentsubmitlabel[0];
        }

        if (doc.labels.attachmentcancellabel[0])
        {
            attachmentCancelLabel = doc.labels.attachmentcancellabel[0];
        }

        if (doc.labels.showattributestext[0])
        {
            showAttributesLabel = doc.labels.showattributestext[0];
        }

        if (doc.labels.noeditablelayerstext[0])
        {
            noEditableLayersLabel = doc.labels.noeditablelayerstextl[0];
        }
    }

    public function exportXML():XML
    {
        var configXML:XML = <configuration>
                <addfeatures>{addFeatures}</addfeatures>
                <deletefeatures>{deleteFeatures}</deletefeatures>
                <updategeometry>{updateGeometry}</updategeometry>
                <updateattributes>{updateAttributes}</updateattributes>
                <toolbarvisible>{toolbarVisible}</toolbarvisible>
                <toolbarcutvisible>{toolbarCut}</toolbarcutvisible>
                <toolbarmergevisible>{toolbarMerge}</toolbarmergevisible>
                <toolbarreshapevisible>{toolbarReshape}</toolbarreshapevisible>
            </configuration>;

        if (formFieldsOrder)
        {
            configXML.appendChild(<formfieldsorder>{formFieldsOrder}</formfieldsorder>);
        }

        appendExcludedLayers(configXML);
        appendLayerSettings(configXML);
        appendLabels(configXML);

        return configXML;
    }

    private function appendLayerSettings(configXML:XML):void
    {
        if (layerSettings.length > 0)
        {
            var layerSettingsXML:XML = <layersettings/>;

            for each (var layerSetting:LayerSettings in layerSettings)
            {
                layerSettingsXML.appendChild(layerSetting.toXML());
            }

            if (layerSettingsXML.children().length() > 0)
            {
                configXML.appendChild(layerSettingsXML);
            }
        }
    }

    private function appendExcludedLayers(configXML:XML):void
    {
        var excludedLayersSource:Array = excludedLayers.source;
        var excludeLayerXML:XML;
        for each (var layerName:String in excludedLayersSource)
        {
            excludeLayerXML = <excludelayer>{layerName}</excludelayer>
            configXML.appendChild(excludeLayerXML);
        }
    }

    private function appendLabels(configXML:XML):void
    {
        var labelsXML:XML = <labels/>

        if (attributesLabel)
        {
            labelsXML.appendChild(<attributeslabel>{attributesLabel}</attributeslabel>);
        }

        if (attachmentsLabel)
        {
            labelsXML.appendChild(<attachmentslabel>{attachmentsLabel}</attachmentslabel>);
        }

        if (relatedRecordsLabel)
        {
            labelsXML.appendChild(<relatedrecordslabel>{relatedRecordsLabel}</relatedrecordslabel>);
        }

        if (featureLayerNotVisibleLabel)
        {
            labelsXML.appendChild(<featurelayernotvisibletext>{featureLayerNotVisibleLabel}</featurelayernotvisibletext>);
        }

        if (saveLabel)
        {
            labelsXML.appendChild(<savelabel>{saveLabel}</savelabel>);
        }

        if (deleteLabel)
        {
            labelsXML.appendChild(<deletelabel>{deleteLabel}</deletelabel>);
        }

        if (showAttachmentsLabel)
        {
            labelsXML.appendChild(<showattachmentstext>{showAttachmentsLabel}</showattachmentstext>);
        }

        if (showRelatedRecordsLabel)
        {
            labelsXML.appendChild(<showrelatedrecords>{showRelatedRecordsLabel}</showrelatedrecords>);
        }

        if (noAttachmentsLabel)
        {
            labelsXML.appendChild(<noattachmentstext>{noAttachmentsLabel}</noattachmentstext>);
        }

        if (chooseFileLabel)
        {
            labelsXML.appendChild(<choosefiletext>{chooseFileLabel}</choosefiletext>);
        }

        if (attachmentSubmitLabel)
        {
            labelsXML.appendChild(<attachmentsubmitlabel>{attachmentSubmitLabel}</attachmentsubmitlabel>);
        }

        if (attachmentCancelLabel)
        {
            labelsXML.appendChild(<attachmentcancellabel>{attachmentCancelLabel}</attachmentcancellabel>);
        }

        if (showAttributesLabel)
        {
            labelsXML.appendChild(<showattributestext>{showAttributesLabel}</showattributestext>);
        }

        if (noEditableLayersLabel)
        {
            labelsXML.appendChild(<noeditablelayerstext>{noEditableLayersLabel}</noeditablelayerstext>);
        }

        if (labelsXML.children().length() > 0)
        {
            configXML.appendChild(labelsXML);
        }
    }

    public function findLayerSettings(layerName:String):LayerSettings
    {
        var matchingLayerSettings:LayerSettings;

        for each (var layerSettingsItem:LayerSettings in layerSettings)
        {
            if (layerSettingsItem.name == layerName)
            {
                matchingLayerSettings = layerSettingsItem;
                break;
            }
        }

        return matchingLayerSettings;
    }
}

}
