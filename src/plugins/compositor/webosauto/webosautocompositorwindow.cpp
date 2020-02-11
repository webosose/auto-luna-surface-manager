/* @@@LICENSE
 *
 * Copyright (c) 2020 LG Electronics, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * LICENSE@@@ */

#include "webosautocompositorwindow.h"
#include "debugtypes.h"

WebOSAutoCompositorWindow::WebOSAutoCompositorWindow(QString screenName, QString geometryString, QSurfaceFormat *surfaceFormat)
    : WebOSCompositorWindow(screenName, geometryString, surfaceFormat)
{
}

bool WebOSAutoCompositorWindow::event(QEvent *e)
{
    switch(e->type()) {
    case QEvent::TouchUpdate: {
        QTouchEvent *touchEvent = static_cast<QTouchEvent*>(e);
        DebugTouchEvent debugTouchEvent;

        foreach (const QTouchEvent::TouchPoint &touchPoint, touchEvent->touchPoints()) {
            DebugTouchPoint *point = new DebugTouchPoint(touchPoint.id());
            point->setNormalizedPos(touchPoint.normalizedPos());
            point->setState(touchPoint.state());
            debugTouchEvent.appendDebugTouchPoint(point);
        }
        emit debugTouchUpdated(&debugTouchEvent);
        break;
    }
    default:
        break;
    }

    return WebOSCompositorWindow::event(e);
}
