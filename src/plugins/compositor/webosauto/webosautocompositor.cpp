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

#include <QGuiApplication>
#include "weboscompositorconfig.h"
#include "webosautocompositor.h"

#include "debugtypes.h"

#include <QtWaylandCompositor/qwaylandxdgshell.h>
#include <QtWaylandCompositor/private/qwaylandpresentationtime_p.h>

WebOSAutoCompositor::WebOSAutoCompositor()
    : WebOSCoreCompositor()
{
    int cursorTimeout = WebOSCompositorConfig::instance()->cursorTimeout();
    if (cursorTimeout > 0) {
        // Set up the cursor timer if the timeout value is given
        m_cursorTimer = new QTimer(this);
        m_cursorTimer->setInterval(cursorTimeout);
        connect(m_cursorTimer, &QTimer::timeout, this, [this] {this->hintCursorVisibility(false);});
        qDebug("Cursor timeout is set as %d", cursorTimeout);
        m_cursorTimer->start();
    } else if (cursorTimeout == 0) {
        // Show the cursor and no visibility control anymore
        hintCursorVisibility(true);
    }

    m_presentation_time = new QWaylandPresentationTime(this);
    if (m_presentation_time && m_presentation_time->isInitialized())
        qInfo() << "PresentationTime is ready";

    // To support some weston client using xdg-shell
    new QWaylandXdgShell(this);
}

void WebOSAutoCompositor::registerTypes()
{
    WebOSCoreCompositor::registerTypes();

    qmlRegisterType<DebugTouchPoint>("WebOSCompositor", 1, 0, "DebugTouchPoint");
    qmlRegisterType<DebugTouchEvent>("WebOSCompositor", 1, 0, "DebugTouchEvent");
}

void WebOSAutoCompositor::hintCursorVisibility(bool visible)
{
    setCursorVisible(visible);
    applyCursorVisibility(visible);
    if (m_cursorTimer) {
        if (visible)
            m_cursorTimer->start();
        else
            m_cursorTimer->stop();
    }
}

void WebOSAutoCompositor::applyCursorVisibility(bool visible)
{
    if (visible) {
        if (m_cursorOverride) {
            qDebug("Cursor turns to visible");
            QGuiApplication::restoreOverrideCursor();
            m_cursorOverride = false;
        }
    } else {
        if (!m_cursorOverride) {
            qDebug("Cursor turns to invisible");
            QGuiApplication::setOverrideCursor(QCursor(Qt::BlankCursor));
            m_cursorOverride = true;
        }
    }
}
