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

#ifndef WEBOSAUTOCOMPOSITORPLUGIN_H
#define WEBOSAUTOCOMPOSITORPLUGIN_H

#include <QObject>
#include <QtPlugin>

#include <WebOSCoreCompositor/weboscompositorinterface.h>

class WebOSAutoCompositorPlugin : public WebOSCompositorInterface
{
    Q_OBJECT

    Q_PLUGIN_METADATA(IID WebOSCompositorInterface_iid FILE "webosautocompositorplugin.json")
    Q_INTERFACES(WebOSCompositorInterface)

public:
    Q_INVOKABLE void init();
    Q_INVOKABLE WebOSCoreCompositor *compositorExtended();
    Q_INVOKABLE WebOSCompositorWindow *compositorWindowExtended(QString screenName = QString(), QString geometryString = QString(), QSurfaceFormat *surfaceFormat = nullptr);
};

#endif // WEBOSAUTOCOMPOSITORPLUGIN_H
