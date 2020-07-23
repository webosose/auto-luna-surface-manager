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
import WebOSCoreCompositor 1.0

BaseLunaServiceAPI {
    id: root

    methods: defaultMethods.concat([
        "setAppMirroring",
        "getAppMirroring"
    ])

    readonly property var mirroringStatus: ["inactive", "sender", "receiver", "disabled"]

    function setAppMirroring(param) {
        var ret = {};
        var mirror = param.mirror;
        var from = param.from;
        var to = param.to;

        console.info("LS2 method handler is called with param: " + JSON.stringify(param));

        if (mirror == undefined || typeof mirror != "boolean" || from == undefined || typeof from != "number" || to == undefined || typeof to != "number") {
            ret.errorCode = 1;
            ret.errorText = "ERR_INVALID_COMMAND";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        if (from < 0 || from >= compositor.windows.length || to < 0 || to >= compositor.windows.length) {
            ret.errorCode = 3;
            ret.errorText = "ERR_INVALID_DISPLAY";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        if (from == to) {
            ret.errorCode = 6;
            ret.errorText = "ERR_SAME_DISPLAY";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        var sourceWindow = compositor.windows[from];
        var targetWindow = compositor.windows[to];

        if (sourceWindow.appMirroringState == CompositorWindow.AppMirroringStateDisabled || targetWindow.appMirroringState == CompositorWindow.AppMirroringStateDisabled) {
            ret.errorCode = 7;
            ret.errorText = "ERR_MIRRORING_DISABLED";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        // Stop App mirroring
        if (!mirror) {
            if (sourceWindow.appMirroringState != CompositorWindow.AppMirroringStateSender || targetWindow.appMirroringState != CompositorWindow.AppMirroringStateReceiver) {
                ret.errorCode = 4;
                ret.errorText = "ERR_NO_MIRRORING";
                console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
                return JSON.stringify(ret);
            }

            if (sourceWindow.stopAppMirroring(to) != 0) {
                ret.errorCode = 10;
                ret.errorText = "INTERNAL_ERROR";
                console.warn("errorText: " + ret.errorText);
            }

            sourceWindow.appMirroringItem = null;
            targetWindow.appMirroringItem = null;

            return JSON.stringify(ret);
        }

        // Start App mirroring
        if (sourceWindow.appMirroringState == CompositorWindow.AppMirroringStateReceiver ||
               targetWindow.appMirroringState == CompositorWindow.AppMirroringStateSender ||
               targetWindow.appMirroringState == CompositorWindow.AppMirroringStateReceiver) {
            ret.errorCode = 5;
            ret.errorText = "ERR_ALREADY_MIRRORING";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        // Error if there is another sender
        for (var i = 0; i < compositor.windows.length; i++) {
            if (from != i && compositor.windows[i].appMirroringState == CompositorWindow.AppMirroringStateSender) {
                ret.errorCode = 5;
                ret.errorText = "ERR_ALREADY_MIRRORING";
                console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
                return JSON.stringify(ret);
            }
        }

        // Set App mirroring item (source)
        if (!sourceWindow.viewsRoot.fullscreen.currentItem) {
            ret.errorCode = 2;
            ret.errorText = "ERR_NO_APP";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }
        sourceWindow.appMirroringItem = Qt.binding(function () { return sourceWindow.viewsRoot.fullscreen.currentItem; });

        // Now the source is inactive or sender
        if (sourceWindow.startAppMirroring(to) != 0) {
            ret.errorCode = 10;
            ret.errorText = "INTERNAL_ERROR";
            console.warn("errorText: " + ret.errorText);
            sourceWindow.appMirroringItem = null;
        } else {
            // Set App mirroring item (target)
            targetWindow.appMirroringItem = Qt.binding(function () { return targetWindow.viewsRoot.fullscreen.currentItem; });
        }

        return JSON.stringify(ret);
    }

    function getAppMirroring(param) {
        function __replySubscription() {
            root.pushSubscription("getAppMirroring", "", "getAppMirroring_response");
        }

        function __subscribe() {
            if (root.subscribersCount("getAppMirroring") == 0) {
                for (var i = 0; i < compositor.windows.length; i++)
                    compositor.windows[i].appMirroringStateChanged.connect(__replySubscription);
                root.subscriptionAboutToCancel.connect(__unsubscribe);
            }
        }

        function __unsubscribe(method) {
            // Count decreases after subscriptionAboutToCancel is handled.
            // So it is the last subscription being cancelled if the count is 1.
            if (method == "getAppMirroring" && root.subscribersCount("getAppMirroring") == 1) {
                for (var i = 0; i < compositor.windows.length; i++)
                    compositor.windows[i].appMirroringStateChanged.disconnect(__replySubscription);
                root.subscriptionAboutToCancel.disconnect(__unsubscribe);
            }
        }

        console.info("LS2 method handler is called with param: " + JSON.stringify(param));

        if (param.subscribe !== undefined && typeof param.subscribe == "boolean" && param.subscribe)
            __subscribe();

        return getAppMirroring_response(param);
    }

    function getAppMirroring_response(param) {
        var ret = {};

        ret.mirroringInfo = [];

        for (var i = 0; i < compositor.windows.length; i++)
            ret.mirroringInfo[i] = JSON.parse('{"displayId":' + i + ',"mirroringStatus":' + JSON.stringify(mirroringStatus[compositor.windows[i].appMirroringState-1]) + '}');

        return JSON.stringify(ret);
    }
}
