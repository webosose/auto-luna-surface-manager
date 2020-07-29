// Copyright (c) 2019-2020 LG Electronics, Inc.
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
        onSurfaceAdded: {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.volume)
                views.volume.hide();
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
        onSurfaceAdded: {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.volume)
                views.volume.hide();
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
        onOpening: {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.volume)
                views.volume.hide();
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
        onSurfaceAdded: {
            if (views.keyboard)
                views.keyboard.closeView();
            if (views.volume)
                views.volume.hide();
            if (views.notification)
                views.notification.hide();
        }
    }

    Connections {
        target: views.homeHotspotBottom
        onTriggered: {
            if (views.home)
                views.home.show();
        }
    }

    Connections {
        target: views.homeHotspotTop
        onTriggered: {
            if (views.home)
                views.home.show();
        }
    }
}
