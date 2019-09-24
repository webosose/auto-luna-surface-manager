// Copyright (c) 2019 LG Electronics, Inc.
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
// FIXME: Remove once WAM supports locationHints finally
import WebOSCoreCompositor 1.0
import WebOSCompositorBase 1.0
import WebOSCompositor 1.0

PopupSurface {
    id: root

    // FIXME-BEGIN: Remove once WAM supports locationHints finally
    property int locationHint: SurfaceItem.LocationHintNorth
    function applyLocationHints() {
        console.log("WebOSAutoSystemUISurface: location hint", root.locationHint);
        // Calculate x and y coordinates instead of using anchors
        // as the parent(PopupView) is not fullscreen anymore.
        if (root.locationHint & SurfaceItem.LocationHintCenter) {
            // The center hint is exclusive, if specified others will not be applied
            x = Qt.binding(function() { return Utils.center(compositorWindow.outputGeometry.width, width); });
            y = Qt.binding(function() { return Utils.center(compositorWindow.outputGeometry.height, height); });
        } else {
            // Align center horizontally, though the horizontal hint(west and east) is unset,
            // if the vertical hint(north and south) is set and vice versa.
            if (root.locationHint & SurfaceItem.LocationHintWest)
                x = 0;
            else if (root.locationHint & SurfaceItem.LocationHintEast)
                x = Qt.binding(function() { return compositorWindow.outputGeometry.width - width; });
            else if (root.locationHint & (SurfaceItem.LocationHintNorth | SurfaceItem.LocationHintSouth))
                x = Qt.binding(function() { return Utils.center(compositorWindow.outputGeometry.width, width); });

            if (root.locationHint & SurfaceItem.LocationHintNorth)
                y = 0;
            else if (root.locationHint & SurfaceItem.LocationHintSouth)
                y = Qt.binding(function() { return compositorWindow.outputGeometry.height - height; });
            else if (root.locationHint & (SurfaceItem.LocationHintWest | SurfaceItem.LocationHintEast))
                y = Qt.binding(function() { return Utils.center(compositorWindow.outputGeometry.height, height); });
        }
    }
    // FIXME-END
}
