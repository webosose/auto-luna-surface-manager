/* @@@LICENSE
 *
 * Copyright (c) 2020-2024 LG Electronics, Inc.
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

#include "webosautocompositor.h"
#include "webosautocompositorwindow.h"
#include "updatescheduler.h"

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

    if (win)
        UpdateScheduler::pageFlipNotifier(win, seq, tv_sec, tv_usec);
}

WebOSAutoCompositorWindow::WebOSAutoCompositorWindow(QString screenName, QString geometryString, QSurfaceFormat *surfaceFormat)
    : WebOSCompositorWindow(screenName, geometryString, surfaceFormat)
{
}

void WebOSAutoCompositorWindow::setPageFlipNotifier()
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

    m_hasPageFlipNotifier = hasPageFlipNotifier;
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
