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
#include "webossurfaceitem.h"
#include <QtQuick/private/qquickitem_p.h>

WebOSAutoCompositorWindow::WebOSAutoCompositorWindow(QString screenName, QString geometryString, QSurfaceFormat *surfaceFormat)
    : WebOSCompositorWindow(screenName, geometryString, surfaceFormat)
{
}

static WebOSSurfaceItem* findWebOSSurfaceItem(QQuickItem *base, const QPointF& point)
{
    if (!base)
        return nullptr;

    if (!base->isVisible() || !base->isEnabled() || QQuickItemPrivate::get(base)->culled)
        return nullptr;

    QList<QQuickItem*> children = QQuickItemPrivate::get(base)->paintOrderChildItems();
    for (int ii = children.count() - 1; ii >= 0; --ii) {
        QQuickItem *child = children.at(ii);
        WebOSSurfaceItem *webosSurfaceItem = findWebOSSurfaceItem(child, point);
        if (webosSurfaceItem)
            return webosSurfaceItem;
    }

    WebOSSurfaceItem *webosSurfaceItem = qobject_cast<WebOSSurfaceItem*>(base);
    if (webosSurfaceItem) {
        if (webosSurfaceItem->isVisible() && webosSurfaceItem->QQuickItem::contains(webosSurfaceItem->mapFromScene(point)))
            return webosSurfaceItem;
    }

    return nullptr;
}

WebOSSurfaceItem* WebOSAutoCompositorWindow::itemAt(const QPointF& point)
{
    return findWebOSSurfaceItem(contentItem(), point);
}

bool WebOSAutoCompositorWindow::event(QEvent *e)
{
    switch(e->type()) {
    case QEvent::TouchBegin:
    case QEvent::TouchEnd:
    case QEvent::TouchUpdate: {
        QTouchEvent *touchEvent = static_cast<QTouchEvent*>(e);
        DebugTouchEvent debugTouchEvent;

        foreach (const QTouchEvent::TouchPoint &touchPoint, touchEvent->touchPoints()) {
            DebugTouchPoint *point = new DebugTouchPoint(touchPoint.id());
            point->setPos(touchPoint.pos());
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
