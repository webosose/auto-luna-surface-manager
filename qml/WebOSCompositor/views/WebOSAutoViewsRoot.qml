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
import WebOSCompositorBase 1.0
import WebOSCompositor 1.0

FocusScope {
    id: root
    focus: true

    property alias fullscreen: fullscreenViewId
    property alias overlay: overlayViewId
    property alias home: homeViewId
    property alias popup: popupViewId
    property alias keyboard: keyboardViewId
    property alias statusbar: statusbarViewId
    property alias statusbarHotspotTop: statusbarHotspotTopId
    property alias voiceAssistant: voiceAssistantViewId
    property alias notification: notificationViewId
    property alias homeHotspotBottom: homeHotspotBottomId

    FullscreenView {
        id: fullscreenViewId
        objectName: "fullscreenView" + compositorWindow.displayId
        anchors.fill: parent
        model: FullscreenWindowModel {
            objectName: "fullscreenWindowModel" + compositorWindow.displayId
        }
    }

    OverlayView {
        id: overlayViewId
        objectName: "overlayView" + compositorWindow.displayId
        anchors.fill: parent
        model: OverlayWindowModel {
            objectName: "overlayWindowModel" + compositorWindow.displayId
        }
    }

    WebOSAutoSystemUIView {
        id: homeViewId
        objectName: "homeView" + compositorWindow.displayId
        layerNumber: 4
        consumeKeyEvents: true
        appId: Settings.local.homeView.appId
        model: WebOSAutoSystemUIWindowModel {
            objectName: "homeWindowModel" + compositorWindow.displayId
            appId: Settings.local.homeView.appId
        }
    }

    PopupView {
        id: popupViewId
        objectName: "popupView" + compositorWindow.displayId
        model: PopupWindowModel {}
    }

    WebOSAutoSystemUIView {
        id: statusbarViewId
        objectName: "statusbar" + compositorWindow.displayId
        layerNumber: 8
        consumeKeyEvents: true
        appId: Settings.local.statusbarView.appId
        model: WebOSAutoSystemUIWindowModel {
            objectName: "statusbarWindowModel" + compositorWindow.displayId
            appId: Settings.local.statusbarView.appId
        }
    }

    KeyboardView {
        id: keyboardViewId
        objectName: "keyboardView" + compositorWindow.displayId
        model: KeyboardWindowModel {}
    }

    WebOSAutoSystemUIView {
        id: voiceAssistantViewId
        objectName: "voiceAssistantView" + compositorWindow.displayId
        layerNumber: 10
        consumeKeyEvents: true
        appId: Settings.local.voiceAssistantView.appId
        model: WebOSAutoSystemUIWindowModel {
            objectName: "voiceAssistantWindowModel" + compositorWindow.displayId
            appId: Settings.local.voiceAssistantView.appId
        }
    }

    WebOSAutoSystemUIView {
        id: notificationViewId
        objectName: "notificationView" + compositorWindow.displayId
        layerNumber: 14
        consumeKeyEvents: true
        appId: Settings.local.notificationView.appId
        model: WebOSAutoSystemUIWindowModel {
            objectName: "notificationWindowModel" + compositorWindow.displayId
            appId: Settings.local.notificationView.appId
        }
    }

    TouchHotspot {
        id: statusbarHotspotTopId
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Settings.local.statusbarView.hotspotThickness
        threshold: Settings.local.statusbarView.hotspotThreshold
        vertical: true
    }

    TouchHotspot {
        id: homeHotspotBottomId
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Settings.local.homeView.hotspotThickness
        threshold: Settings.local.homeView.hotspotThreshold
        vertical: true
        reverse: true
    }

    Loader {
        anchors.fill: parent
        source: Settings.local.debug.enable ? "debug/WebOSAutoDebugOverlay.qml" : ""
    }
}
