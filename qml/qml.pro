# Copyright (c) 2019-2020 LG Electronics, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

TEMPLATE = aux

use_qresources {
    maindir = $$PWD/WebOSCompositor
    mainqrc = $$maindir/WebOSCompositor.qrc
    system(./makeqrc.sh -prefix WebOSCompositor $$maindir $$mainqrc)

    mainrcc = $$PWD/WebOSCompositor.rcc
    system(rcc -binary $$mainqrc -o $$mainrcc)
    system(rm -f $$mainqrc)
    QMAKE_CLEAN += $$mainrcc

    rcc.files = $$mainrcc
    rcc.path = $$WEBOS_INSTALL_QML/WebOSCompositor
    INSTALLS += rcc
} else {
    qmlfiles.files = WebOSCompositor
    qmlfiles.path = $$WEBOS_INSTALL_QML/WebOSCompositor/AutoRSE
    INSTALLS += qmlfiles
}
