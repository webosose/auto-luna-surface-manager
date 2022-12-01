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

Item {
    id: root

    property var access
    property var keyController
    property var views

    WebOSAutoDebugPatternController { }

    Connections {
        target: views.fullscreen
        function onSurfaceAdded(item) {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.statusbar)
                views.statusbar.hide();
            if (views.notification)
                views.notification.hide();
            if (views.popup)
                views.popup.closeView();
            if (views.home)
                views.home.hide();
            if (views.overlay)
                views.overlay.closeView();
        }
    }

    Connections {
        target: views.overlay
        function onSurfaceAdded(item) {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.statusbar)
                views.statusbar.hide();
            if (views.notification)
                views.notification.hide();
            if (views.popup)
                views.popup.closeView();
            if (views.home)
                views.home.hide();
        }
    }

    Connections {
        target: views.home
        function onOpening() {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.statusbar)
                views.statusbar.hide();
            if (views.notification)
                views.notification.hide();
            if (views.popup)
                views.popup.closeView();
            if (views.overlay)
                views.overlay.closeView();
        }
    }

    Connections {
        target: views.popup
        function onSurfaceAdded(item) {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.statusbar)
                views.statusbar.hide();
            if (views.notification)
                views.notification.hide();
        }
    }

    Connections {
        target: views.homeHotspotBottom
        function onTriggered() {
            if (views.home)
                views.home.show();
        }
    }

    Connections {
        target: views.statusbarHotspotTop
        function onTriggered() {
            if (views.statusbar)
                views.statusbar.show();
        }
    }

    Connections {
        target: keyController
        function onHomePressed() {
            var homeView = compositor.windows[compositor.currentMouseDisplayId()].viewsRoot.home;
            if (homeView) {
                if (homeView.isOpen)
                    homeView.hide();
                else
                    homeView.show();
            }
        }

        function onSettingsPressed() {
            var params = {};
            var displayId = compositor.currentMouseDisplayId();
            params["displayAffinity"] = displayId;
            var sessionId = LS.sessionManager.sessionId;
            if (!sessionId)
                console.warn("sessionId is not valid");

            var appId = "com.palm.app.settings";
            var foregroundItems = Utils.foregroundList(compositor.windows[displayId].viewsRoot.children);
            for (var i = 0; i < foregroundItems.length; i++) {
                if (foregroundItems[i].appId == appId) {
                    var overlayView = compositor.windows[displayId].viewsRoot.overlay;
                    if (overlayView)
                        overlayView.closeView();
                    return;
                }
            }

            console.info("launching the target app:", appId + ' (with sessionId: ' + sessionId + ')');
            LS.adhoc.call("luna://com.webos.applicationManager", "/launch",
                "{\"id\":\"" + appId + "\", \"params\":" + JSON.stringify(params) + "}", undefined, sessionId);
        }
    }
}
