// @@@LICENSE
//
// Copyright (c) 2019 LG Electronics, Inc.
//
// Confidential computer software. Valid license from LG required for
// possession, use or copying. Consistent with FAR 12.211 and 12.212,
// Commercial Computer Software, Computer Software Documentation, and
// Technical Data for Commercial Items are licensed to the U.S. Government
// under vendor's standard commercial license.
//
// LICENSE@@@

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

        if (sourceWindow.mirroringState == CompositorWindow.MirroringStateDisabled || targetWindow.mirroringState == CompositorWindow.MirroringStateDisabled) {
            ret.errorCode = 7;
            ret.errorText = "ERR_MIRRORING_DISABLED";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        // Stop mirroring
        if (!mirror) {
            if (sourceWindow.mirroringState != CompositorWindow.MirroringStateSender || targetWindow.mirroringState != CompositorWindow.MirroringStateReceiver) {
                ret.errorCode = 4;
                ret.errorText = "ERR_NO_MIRRORING";
                console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
                return JSON.stringify(ret);
            }

            if (sourceWindow.stopMirroring(to) != 0) {
                ret.errorCode = 10;
                ret.errorText = "INTERNAL_ERROR";
                console.warn("errorText: " + ret.errorText);
            }
            return JSON.stringify(ret);
        }

        // Start mirroring

        if (sourceWindow.mirroringState == CompositorWindow.MirroringStateReceiver ||
               targetWindow.mirroringState == CompositorWindow.MirroringStateSender ||
               targetWindow.mirroringState == CompositorWindow.MirroringStateReceiver) {
            ret.errorCode = 5;
            ret.errorText = "ERR_ALREADY_MIRRORING";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        if (!sourceWindow.fullscreenItem) {
            ret.errorCode = 2;
            ret.errorText = "ERR_NO_APP";
            console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
            return JSON.stringify(ret);
        }

        // Error if there is another sender
        for (var i = 0; i < compositor.windows.length; i++) {
            if (from != i && compositor.windows[i].mirroringState == CompositorWindow.MirroringStateSender) {
                ret.errorCode = 5;
                ret.errorText = "ERR_ALREADY_MIRRORING";
                console.warn("errorCode: " + ret.errorCode + ", errorText: " + ret.errorText);
                return JSON.stringify(ret);
            }
        }

        // Now the source is inactive or sender
        if (sourceWindow.startMirroring(to) != 0) {
            ret.errorCode = 10;
            ret.errorText = "INTERNAL_ERROR";
            console.warn("errorText: " + ret.errorText);
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
                    compositor.windows[i].mirroringStateChanged.connect(__replySubscription);
                root.subscriptionAboutToCancel.connect(__unsubscribe);
            }
        }

        function __unsubscribe(method) {
            // Count decreases after subscriptionAboutToCancel is handled.
            // So it is the last subscription being cancelled if the count is 1.
            if (method == "getAppMirroring" && root.subscribersCount("getAppMirroring") == 1) {
                for (var i = 0; i < compositor.windows.length; i++)
                    compositor.windows[i].mirroringStateChanged.disconnect(__replySubscription);
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
            ret.mirroringInfo[i] = JSON.parse('{"displayId":' + i + ',"mirroringStatus":' + JSON.stringify(mirroringStatus[compositor.windows[i].mirroringState-1]) + '}');

        return JSON.stringify(ret);
    }
}
