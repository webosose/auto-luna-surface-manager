// Copyright (c) 2020 LG Electronics, Inc.
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

QtObject {
    property var list: [
        {
            service: "com.webos.service.sessionmanager",
            method: "getSessionList",
            handler: function (response) {
                if (response.sessionList !== undefined) {
                    var sessionList = response.sessionList;
                    if (sessionList && sessionList.length > 0) {
                        for (var i = 0; i < sessionList.length; i++) {
                            if (sessionList[i].deviceSetInfo.displayId == compositorWindow.displayId)
                                return sessionList[i].sessionId;
                        }
                    }
                }
                return undefined;
            }
        }
    ]
}
