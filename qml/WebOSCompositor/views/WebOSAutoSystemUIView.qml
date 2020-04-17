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

SystemUIView {
    id: root
    containerQml: Qt.resolvedUrl("./WebOSAutoSystemUISurface.qml")

    property string appId: ""

    function show() {
        var params = {};
        params["displayAffinity"] = compositorWindow.displayId;
        /* FIXME
        var sessionId = SessionManager.getSessionByDisplay(compositorWindow.displayId);
        if (!sessionId)
            console.warn("WebOSAutoSystemUIView: sessionId is not valid");
        console.info("WebOSAutoSystemUIView: launching the target app:", root.appId + ' (with sessionId: ' + sessionId + ')');
        LS.adhoc.call("luna://com.webos.applicationManager", "/launch",
            "{\"id\":\"" + root.appId + "\", \"params\":" + JSON.stringify(params) + "}", undefined, sessionId);
        */
        console.info("WebOSAutoSystemUIView: launching the target app:", root.appId);
        LS.adhoc.call("luna://com.webos.applicationManager", "/launch",
            "{\"id\":\"" + root.appId + "\", \"params\":" + JSON.stringify(params) + "}");
    }

    function hide() {
        if (currentItem) {
            console.info("WebOSAutoSystemUIView: closing currentItem:", currentItem.appId);
            currentItem.close();
        }
    }
}
