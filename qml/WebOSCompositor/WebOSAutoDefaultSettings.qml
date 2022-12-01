// Copyright (c) 2019-2022 LG Electronics, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

import QtQuick 2.4
import WebOS.Global 1.0

QtObject {
    readonly property url imagePath: Qt.resolvedUrl("resources/images/")
    readonly property url imagePathBase: "file://" + WebOS.qmlDir + "/WebOSCompositorBase/resources/images/"
    readonly property var settings: {
        "addon": {
            "directories": [
                "file://" + WebOS.applicationDir + "/"
            ]
        },
        "compositor": {
            "geometryPendingInterval": 2000
        },
        "debug": {
            "enable": false,
            "compositorBorder": false,
            "focusHighlight": false,
            "surfaceHighlight": false,
            "touchHighlight": false,
            "fpsGraphOverlay": false,
            "spinnerRepaint": false,
            "touchOverlay": false,
            "resourceMonitor": false,
            "logConsole": false,
            "logFilter": {
                "debug": true,
                "warning": true,
                "critical": true,
                "fatal": true
            },
            "focusConsole": false,
            "surfaceConsole": false,
            "debugWindow": {
                "x": 100,
                "y": 100,
                "width": 600,
                "height": 500,
                "opacity": 0.8
            }
        },
        "homeView": {
            "appId": "com.webos.app.home",
            "hotspotThickness": 10,
            "hotspotThreshold": 100
        },
        "imageResources": {
            "settings": imagePathBase + "settings.png",
            "spinner": imagePathBase + "spinner.gif"
        },
        "keyboardView": {
            "height": 324,
            "slideAnimationDuration": 500
        },
        "localization": {
            "imports": []
        },
        "notificationView": {
            "appId": "com.webos.app.notification"
        },
        "statusbarView": {
            "appId": "com.webos.app.statusbar",
            "hotspotThickness": 10,
            "hotspotThreshold": 100
        },
        "voiceAssistantView": {
            "appId": "com.webos.app.alexaauto"
        }
    }
}
