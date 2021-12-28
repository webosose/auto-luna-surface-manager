// Copyright (c) 2022 LG Electronics, Inc.
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
import WebOSCoreCompositor 1.0

Item {
    id: root

    property var access
    property var viewState
    property var views

    signal homePressed()
    signal settingsPressed()

    KeyFilter {
        id: keyFilter

        keyFilterFallback: "defaultKeyEventHandler"

        function defaultKeyEventHandler(key, pressed, autoRepeat) {
            switch (key) {
                case Qt.Key_Super_L:
                    if (pressed && !autoRepeat)
                        root.homePressed();
                    return KeyPolicy.Accepted;
                case Qt.Key_F1:
                    if (pressed && !autoRepeat)
                        root.settingsPressed();
                    return KeyPolicy.Accepted;
            }
            return KeyPolicy.NotAccepted;
        }
    }

    // Set keyFilter for compositor
    // TODO: Add an interface for KeyFilter.compositor, then remove this
    Binding {
        target: compositor
        property: "keyFilter"
        value: keyFilter
    }
}
