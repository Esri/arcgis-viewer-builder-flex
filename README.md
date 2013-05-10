# arcgis-viewer-builder-flex

This is the source code for the ArcGIS Viewer for Flex Application Builder (a.k.a Flex Viewer Application Builder). Learn more about Flex Viewer Application Builder at [ArcGIS Viewer for Flex resource center](http://links.esri.com/flexviewer).

## Overview
The ArcGIS Viewer for Flex Application Builder enables quick and easy creation of new web mapping applications, as well as view and modify existing web applications. It is designed to make the process seamless without requiring programming or configuration file editing.
The application builder is targeted to users who intend to create custom web mapping applications through a WYSIWYG look and feel. It is comes packaged as an Adobe AIR file that includes a what-you-see-is-what-you-get (WYSIWYG) interface.
The application builder has a simple three-stage process where you define the data content, functionality, and appearance of a web mapping application. It's designed to help novice users learn about the different ArcGIS Viewer configuration properties, as well as create and deploy new web mapping applications effortlessly.

## Instructions (Getting Started)

There are three different ways of getting the source code from the GitHub web site: clone, [fork](https://help.github.com/articles/fork-a-repo) and download zip.  See http://links.esri.com/flexviewer-gettingstarted-developers for more details.

Once you have the source code on your own machine, you need to import it into Adobe Flash Builder:

1. In Adobe Flash Builder 4.6 or 4.7, go to "File" -> "New" -> "Flex Project" and:
    * Set "Name to "ArcGIS Viewer for Flex"
    * Under "Project location"
        * Uncheck "Use default location"
        * Set "Path" to repository root
    * Set "Application type" to "Desktop (runs in Adobe AIR)"
    * Under "Flex SDK version"
        * Select "Use specific SDK"
        * Select "4.9.1 + 3.5 AIR" (see [Overlay AIR SDK on Flex SDK](http://helpx.adobe.com/x-productkb/multi/how-overlay-air-sdk-flex-sdk.html) for more information)

2. Click "Next" until you reach "Build Paths"
    * Under "Library Path"
        * If you haven't done so already, download the API Library from http://links.esri.com/flex-api/latest-download and unzip it.
        * Click "Add SWC" and navigate to the agslib-3.[*]-[YYYY-MM-DD].swc API library file.
    * Under "Source Path"
        * Click on "Add Folder" and navigate to parent folder containing the compiled Flex Viewer.
    * Set "Main application file" to "Builder.mxml"
    * Set "Application ID" to "com.esri.ags.AppBuilder3.0.1"

3. Click "Finish" button. Project will be created and displayed in the Package Explorer window of Adobe Flash Builder.

Optionally:

* To include widget modules:
    * Under "Package Explorer", right-click on the project and select "Properties"
    * Go to "Flex Modules" and add any desired widget modules. *Modules are located at src/modules/<MODULE NAME>/<MODULE NAME>Module.as

* To include locales:
    * Under "Package Explorer", right-click on the project and select "Properties"
    * Go to "Flex Compiler" and add any desired locales * Note that you may need to create some locales if unsupported by the Flex SDK. See [Localization](http://resources.arcgis.com/en/help/flex-api/concepts/index.html#//017p00000007000000) for more information.

## Requirements

* Knowledge of Flex development.
* A little background with Adobe/Apache Flex SDK.
* Experience with the [ArcGIS API for Flex](http://links.esri.com/flex) would help.

## Resources

* [ArcGIS Viewer for Flex Resource Center](http://links.esri.com/flexviewer)
* [ArcGIS API for Flex Resource Center](http://links.esri.com/flex)
* [Flex Viewer Application Builder License agreement](http://www.apache.org/licenses/LICENSE-2.0.html)
* [Flex API License agreement](http://www.esri.com/legal/pdfs/mla_e204_e300/english.pdf)
* [Flex Viewer forum](http://forums.arcgis.com/forums/111-ArcGIS-Viewer-for-Flex)
* [ArcGIS Blog](http://blogs.esri.com/esri/arcgis/tag/flex/)
* [twitter@esri](http://twitter.com/esri)

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an [issue](https://github.com/Esri/arcgis-viewer-builder-flex/issues).

## Contributing

Anyone and everyone is welcome to [contribute](CONTRIBUTING.md).

## Licensing
Copyright 2012-2013 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [license.txt](https://raw.github.com/Esri/arcgis-viewer-builder-flex/develop/license.txt) file.

[](Esri Tags: ArcGIS Web Flex Viewer Application Builder Map Library API)
[](Esri Language: ActionScript)

