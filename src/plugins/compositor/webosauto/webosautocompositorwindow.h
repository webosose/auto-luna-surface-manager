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

#ifndef WEBOSAUTOCOMPOSITORWINDOW_H
#define WEBOSAUTOCOMPOSITORWINDOW_H

#include <WebOSCoreCompositor/weboscompositorwindow.h>
#include "webosautocompositor.h"

class WebOSAutoCompositor;

class WebOSAutoCompositorWindow : public WebOSCompositorWindow
{
    Q_OBJECT

public:
    explicit WebOSAutoCompositorWindow(QString screenName = QString(), QString geometryString = QString(), QSurfaceFormat *surfaceFormat = 0);

    void setPageFlipNotifier();
    void invalidateCursor() override;

    WebOSAutoCompositor *compositor() const { return qobject_cast<WebOSAutoCompositor*>(WebOSCompositorWindow::compositor()); }

protected:
    bool event(QEvent *e) override;
};

#endif // WEBOSAUTOCOMPOSITORWINDOW_H
