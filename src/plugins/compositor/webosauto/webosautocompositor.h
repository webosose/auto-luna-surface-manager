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

#ifndef WEBOSAUTOCOMPOSITOR_H
#define WEBOSAUTOCOMPOSITOR_H

#include <QTimer>

#include <WebOSCoreCompositor/weboscorecompositor.h>

class QWaylandPresentationTime;

class WebOSAutoCompositor : public WebOSCoreCompositor {
    Q_OBJECT

public:
    WebOSAutoCompositor();

    void registerTypes() override;
    bool useCursorTimeout() const { return (m_cursorTimer != nullptr); }
    void hintCursorVisibility(bool visible);
    void applyCursorVisibility(bool visible);

    QWaylandPresentationTime *presentationTime() const { return m_presentation_time; }

private:
    bool m_cursorOverride = false;
    QTimer *m_cursorTimer = nullptr;

    QWaylandPresentationTime *m_presentation_time = nullptr;
};

#endif // WEBOSAUTOCOMPOSITOR_H
