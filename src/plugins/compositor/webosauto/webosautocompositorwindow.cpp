/* @@@LICENSE
 *
 * Copyright (c) 2020-2021 LG Electronics, Inc.
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

#include <QtQuick/private/qquickitem_p.h>
#include "webossurfaceitem.h"
#include "webosautocompositor.h"
#include "webosautocompositorwindow.h"
#include "debugtypes.h"

#include <QGuiApplication>
#include <qpa/qplatformscreen.h>
#include <qpa/qplatformnativeinterface.h>
#include <QtWaylandCompositor/private/qwaylandpresentationtime_p.h>

static void pageFlipNotifier(void *key, unsigned int seq, unsigned int tv_sec, unsigned int tv_usec)
{
    WebOSAutoCompositorWindow* win =
        static_cast<WebOSAutoCompositorWindow*>(static_cast<QPlatformScreen*>(key)->windows()[0]);

    QWaylandPresentationTime *ptTime = win ? win->compositor()->presentationTime() : nullptr;
    if (ptTime)
        ptTime->sendFeedback(win, seq, tv_sec, tv_usec*1000);
}

WebOSAutoCompositorWindow::WebOSAutoCompositorWindow(QString screenName, QString geometryString, QSurfaceFormat *surfaceFormat)
    : WebOSCompositorWindow(screenName, geometryString, surfaceFormat)
{
    static bool hasPageFlipNotifier = [] {
        typedef void(**pFn)(void *key, unsigned int seq, unsigned int tv_sec, unsigned int tv_usec);
        void* addr = QGuiApplication::platformNativeInterface()->
            nativeResourceForIntegration("dri_address_of_page_flip_notifier");
        if (addr) {
            std::atomic<pFn> pPageFlipNotifier((pFn)addr);
            *pPageFlipNotifier = &::pageFlipNotifier;
            qInfo() << "Set pageFlipNotifier as the page flip notifier";
            return true;
        }
        return false;
    }();
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

void WebOSAutoCompositorWindow::invalidateCursor()
{
    // As this can be called as a result of cursorVisible change
    // we should call applyCursorVisibility directly here.
    WebOSAutoCompositor *c = static_cast<WebOSAutoCompositor *>(compositor());
    if (c && (c->useCursorTimeout() || WebOSCompositorConfig::instance()->cursorTimeout() == -1))
        c->applyCursorVisibility(false);
}

bool WebOSAutoCompositorWindow::event(QEvent *e)
{
    switch(e->type()) {
    case QEvent::TouchBegin:
    case QEvent::TouchEnd:
    case QEvent::TouchUpdate: {
        QTouchEvent *touchEvent = static_cast<QTouchEvent*>(e);
        DebugTouchEvent debugTouchEvent;

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        foreach (const QTouchEvent::TouchPoint &touchPoint, touchEvent->points()) {
            DebugTouchPoint *point = new DebugTouchPoint(touchPoint.id());
            point->setPos(touchPoint.position());
            point->setNormalizedPos(touchPoint.normalizedPosition());
            point->setState(touchPoint.state());
            debugTouchEvent.appendDebugTouchPoint(point);
        }
#else
        foreach (const QTouchEvent::TouchPoint &touchPoint, touchEvent->touchPoints()) {
            DebugTouchPoint *point = new DebugTouchPoint(touchPoint.id());
            point->setPos(touchPoint.pos());
            point->setNormalizedPos(touchPoint.normalizedPos());
            point->setState(touchPoint.state());
            debugTouchEvent.appendDebugTouchPoint(point);
        }
#endif
        emit debugTouchUpdated(&debugTouchEvent);
        break;
    }
    default:
        break;
    }

    // NOTE: This cursor visiblity control refers to what libim has.
    WebOSAutoCompositor *c = static_cast<WebOSAutoCompositor *>(compositor());
    if (c && (c->useCursorTimeout() || WebOSCompositorConfig::instance()->cursorTimeout() == -1)) {
        switch (e->type()) {
        case QEvent::KeyPress:
            switch ((static_cast<QKeyEvent *>(e))->key()) {
            case Qt::Key_Left:
            case Qt::Key_Up:
            case Qt::Key_Right:
            case Qt::Key_Down:
                c->hintCursorVisibility(false);
                break;
            default:
                break;
            }
            break;

        case QEvent::MouseButtonPress:
        case QEvent::MouseButtonRelease:
        case QEvent::MouseMove:
        case QEvent::Wheel:
            c->hintCursorVisibility(true);
            break;
        default:
            break;
        }
    }

    return WebOSCompositorWindow::event(e);
}
